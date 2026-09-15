-- =====================================================================
-- 077 - Periodo gratuito (general y por cliente), previo al cobro real
-- =====================================================================
-- Antes de empezar a cobrar, habrá un periodo de regalo pensado para captar tráfico y usuarios:
-- mientras esté activo, un cliente puede publicar/avisar/añadir sedes aunque su plan no esté
-- marcado como pagado (076). Se configura con fecha de inicio y fecha de fin:
--   - Sin fecha de fin = indefinido (nunca caduca mientras no se le ponga una).
--   - Se puede definir con carácter general (TConfiguracionGlobal, aplica a todos) y también
--     específico por cliente (TSistemaUsuarios, para regalar más tiempo a alguien en concreto).
--   - Si un cliente tiene uno propio definido, prevalece el que tenga la fecha de fin más
--     lejana entre el general y el suyo (indefinido siempre gana, por ser "el más lejano" que
--     existe); si no tiene uno propio, se usa solo el general.
--
-- Requiere que 076 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD COLUMN "PeriodoGratuitoInicio" timestamptz NULL,
    ADD COLUMN "PeriodoGratuitoFin" timestamptz NULL;

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "PeriodoGratuitoInicio" timestamptz NULL,
    ADD COLUMN "PeriodoGratuitoFin" timestamptz NULL;

-- =====================================================================
-- Resuelve si un cliente está hoy dentro de su periodo gratuito (general, propio, o ninguno).
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaClienteEnPeriodoGratuito"(p_id_sistema_usuario uuid)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_global_inicio timestamptz;
    v_global_fin timestamptz;
    v_cliente_inicio timestamptz;
    v_cliente_fin timestamptz;
    v_inicio timestamptz;
    v_fin timestamptz;
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
        -- El cliente no tiene periodo propio: solo cuenta el general.
        v_usar_cliente := false;
    ELSIF v_global_inicio IS NULL THEN
        -- No hay periodo general definido: gana el del cliente por descarte.
        v_usar_cliente := true;
    ELSIF v_cliente_fin IS NULL THEN
        -- El del cliente es indefinido: nada le gana.
        v_usar_cliente := true;
    ELSIF v_global_fin IS NULL THEN
        -- El general es indefinido y el del cliente no: gana el general.
        v_usar_cliente := false;
    ELSE
        -- Los dos tienen fecha de fin: gana la más lejana.
        v_usar_cliente := v_cliente_fin >= v_global_fin;
    END IF;

    IF v_usar_cliente THEN
        v_inicio := v_cliente_inicio;
        v_fin := v_cliente_fin;
    ELSE
        v_inicio := v_global_inicio;
        v_fin := v_global_fin;
    END IF;

    IF v_inicio IS NULL THEN
        RETURN false;
    END IF;

    RETURN now() >= v_inicio AND (v_fin IS NULL OR now() <= v_fin);
END;
$$;

-- =====================================================================
-- Los triggers de 076 pasan a permitir también el periodo gratuito, no solo "PlanPagado".
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoPorSede"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sistema_usuario uuid;
    v_pagado boolean;
BEGIN
    SELECT u."IdSistemaUsuario", u."PlanPagado"
        INTO v_id_sistema_usuario, v_pagado
        FROM "TClienteSedes" s
        JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
        WHERE s."IdClienteSede" = NEW."IdClienteSede";

    IF v_pagado IS NOT TRUE AND NOT "FSistemaClienteEnPeriodoGratuito"(v_id_sistema_usuario) THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoTClienteSedes"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_pagado boolean;
BEGIN
    SELECT "PlanPagado" INTO v_pagado
        FROM "TSistemaUsuarios"
        WHERE "IdSistemaUsuario" = NEW."IdSistemaUsuario";

    IF v_pagado IS NOT TRUE
        AND NOT "FSistemaClienteEnPeriodoGratuito"(NEW."IdSistemaUsuario") THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;
