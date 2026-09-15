-- =====================================================================
-- 078 - Estado de suscripción del propio cliente (RPC de autoservicio)
-- =====================================================================
-- Cuando un cliente activa su cuenta y acepta las condiciones, necesita un sitio al que acudir
-- para ver el estado de su suscripción y, en cuanto termine su periodo gratuito (077) sin tener
-- el plan pagado, un punto de partida para regularizarlo. El proceso de pago en sí (pasarela)
-- queda para más adelante: por ahora ese punto de partida es contactar con soporte, igual que ya
-- se hace en el resto de la app.
--
-- Se separa de "FSistemaClienteEnPeriodoGratuito" (077) la parte de "qué periodo aplica" en su
-- propia función, para no repetir la lógica de "cuál gana" (general vs. propio) en dos sitios:
-- esa función y la nueva RPC de autoservicio se apoyan las dos en esta.
--
-- Requiere que 077 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaPeriodoGratuitoAplicable"(p_id_sistema_usuario uuid)
RETURNS TABLE ("Inicio" timestamptz, "Fin" timestamptz)
LANGUAGE plpgsql
AS $$
DECLARE
    v_global_inicio timestamptz;
    v_global_fin timestamptz;
    v_cliente_inicio timestamptz;
    v_cliente_fin timestamptz;
    v_usar_cliente boolean;
BEGIN
    SELECT "PeriodoGratuitoInicio", "PeriodoGratuitoFin"
        INTO v_global_inicio, v_global_fin
        FROM "TConfiguracionGlobal";

    SELECT "PeriodoGratuitoInicio", "PeriodoGratuitoFin"
        INTO v_cliente_inicio, v_cliente_fin
        FROM "TSistemaUsuarios"
        WHERE "IdSistemaUsuario" = p_id_sistema_usuario;

    IF v_cliente_inicio IS NULL THEN
        v_usar_cliente := false;
    ELSIF v_global_inicio IS NULL THEN
        v_usar_cliente := true;
    ELSIF v_cliente_fin IS NULL THEN
        v_usar_cliente := true;
    ELSIF v_global_fin IS NULL THEN
        v_usar_cliente := false;
    ELSE
        v_usar_cliente := v_cliente_fin >= v_global_fin;
    END IF;

    IF v_usar_cliente THEN
        RETURN QUERY SELECT v_cliente_inicio, v_cliente_fin;
    ELSE
        RETURN QUERY SELECT v_global_inicio, v_global_fin;
    END IF;
END;
$$;

-- Mismo comportamiento que antes (077), reescrita para apoyarse en la función de arriba.
CREATE OR REPLACE FUNCTION "FSistemaClienteEnPeriodoGratuito"(p_id_sistema_usuario uuid)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_inicio timestamptz;
    v_fin timestamptz;
BEGIN
    SELECT "Inicio", "Fin" INTO v_inicio, v_fin
        FROM "FSistemaPeriodoGratuitoAplicable"(p_id_sistema_usuario);

    IF v_inicio IS NULL THEN
        RETURN false;
    END IF;

    RETURN now() >= v_inicio AND (v_fin IS NULL OR now() <= v_fin);
END;
$$;

-- =====================================================================
-- RPC de autoservicio: solo lee datos que el propio llamante ya puede ver por RLS (su propia
-- fila de TSistemaUsuarios y la fila única de TConfiguracionGlobal), así que no hace falta
-- SECURITY DEFINER. Resuelve siempre "auth.uid()", nunca recibe un id ajeno.
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaMiEstadoSuscripcion"()
RETURNS TABLE (
    "PlanPagado" boolean,
    "EnPeriodoGratuito" boolean,
    "PeriodoGratuitoFin" timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sistema_usuario uuid;
    v_pagado boolean;
    v_periodo_fin timestamptz;
BEGIN
    SELECT "IdSistemaUsuario", "PlanPagado"
        INTO v_id_sistema_usuario, v_pagado
        FROM "TSistemaUsuarios"
        WHERE "IdAuthSupabase" = auth.uid();

    IF v_id_sistema_usuario IS NULL THEN
        RETURN;
    END IF;

    SELECT "Fin" INTO v_periodo_fin
        FROM "FSistemaPeriodoGratuitoAplicable"(v_id_sistema_usuario);

    RETURN QUERY SELECT
        v_pagado,
        "FSistemaClienteEnPeriodoGratuito"(v_id_sistema_usuario),
        v_periodo_fin;
END;
$$;

GRANT EXECUTE ON FUNCTION "FSistemaMiEstadoSuscripcion"() TO authenticated;
