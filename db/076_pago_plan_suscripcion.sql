-- =====================================================================
-- 076 - Bloqueo por plan no pagado (interruptor manual, sin pasarela de pago todavía)
-- =====================================================================
-- Mientras no exista el cobro real (el cliente eligiendo y pagando su propio plan), el ADMIN
-- marca a mano si un cliente está "al día" o no. Si no lo está, no puede publicar esquelas,
-- enviar avisos ni añadir sedes (tampoco programar ninguna de las dos cosas, para no poder
-- rodear el bloqueo dejándolo programado).
--
-- Los clientes que YA existen hoy arrancan en "pagado" para no cortar a nadie de golpe: el
-- interruptor queda listo para usarse desde ahora, tanto para clientes nuevos (que arrancan en
-- "no pagado" hasta que el ADMIN confirme el pago) como para desactivar a uno existente si hiciera
-- falta.
--
-- Requiere que 075 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "PlanPagado" boolean NOT NULL DEFAULT false;

UPDATE "TSistemaUsuarios" u
SET "PlanPagado" = true
WHERE EXISTS (
    SELECT 1
    FROM "TSistemaUsuariosRoles" r
    JOIN "TSistemaRoles" ro ON ro."IdSistemaRol" = r."IdSistemaRol"
    WHERE r."IdSistemaUsuario" = u."IdSistemaUsuario" AND ro."Codigo" = 'CLIENTE'
);

-- =====================================================================
-- Trigger reutilizable: bloquea el INSERT si el cliente dueño de la sede no tiene "PlanPagado".
-- Se usa en las tablas "reales" (TClientePublicaciones/TClienteAvisos) y en las "programadas"
-- (055) para que tampoco se pueda rodear el bloqueo dejando algo en cola; en todas ellas la
-- columna que identifica la sede es "IdClienteSede".
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoPorSede"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_pagado boolean;
BEGIN
    SELECT u."PlanPagado" INTO v_pagado
    FROM "TClienteSedes" s
    JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
    WHERE s."IdClienteSede" = NEW."IdClienteSede";

    IF v_pagado IS NOT TRUE THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_ValidarPlanPagado_TClientePublicaciones"
    BEFORE INSERT ON "TClientePublicaciones"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarPlanPagadoPorSede"();

CREATE TRIGGER "trigger_ValidarPlanPagado_TClientePublicacionesProgramadas"
    BEFORE INSERT ON "TClientePublicacionesProgramadas"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarPlanPagadoPorSede"();

CREATE TRIGGER "trigger_ValidarPlanPagado_TClienteAvisos"
    BEFORE INSERT ON "TClienteAvisos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarPlanPagadoPorSede"();

CREATE TRIGGER "trigger_ValidarPlanPagado_TClienteAvisosProgramados"
    BEFORE INSERT ON "TClienteAvisosProgramados"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarPlanPagadoPorSede"();

-- =====================================================================
-- TClienteSedes: variante propia porque aquí el dueño se identifica directamente por
-- "IdSistemaUsuario" (todavía no hay sede sobre la que apoyarse). Trigger independiente del de
-- límite de sedes (075, "FSistemaValidarLimiteSedes"): con dos triggers BEFORE INSERT en la
-- misma tabla, salta el que corresponda sin tener que tocar el ya existente.
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoTClienteSedes"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_pagado boolean;
BEGIN
    SELECT u."PlanPagado" INTO v_pagado
    FROM "TSistemaUsuarios" u
    WHERE u."IdSistemaUsuario" = NEW."IdSistemaUsuario";

    IF v_pagado IS NOT TRUE THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_ValidarPlanPagado_TClienteSedes"
    BEFORE INSERT ON "TClienteSedes"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarPlanPagadoTClienteSedes"();
