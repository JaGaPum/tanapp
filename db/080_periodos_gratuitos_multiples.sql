-- =====================================================================
-- 080 - Periodos gratuitos como lista gestionable (CRUD), no un único par de fechas
-- =====================================================================
-- Cambio de modelo respecto a 077/078/079: en vez de una sola pareja Inicio/Fin por ámbito
-- (general en TConfiguracionGlobal, propio en TSistemaUsuarios), ahora cada ámbito tiene una
-- lista de periodos independientes. Se puede dar de alta uno nuevo, editarlo o borrarlo sin
-- afectar a los demás, y los que ya hayan caducado se quedan ahí como histórico en vez de
-- machacarse. "Inicio" sigue siendo obligatorio en cada periodo (no se puede dar de alta uno sin
-- fecha de inicio); "Fin" en blanco sigue significando indefinido para ESE periodo.
--
-- Un cliente está en periodo gratuito si AHORA MISMO cae dentro de CUALQUIER periodo activo, sea
-- general o suyo propio -ya no hace falta decidir "cuál gana" porque puede haber varios a la
-- vez-. Para mostrarle hasta cuándo (ver "Mi suscripción"), se toma el "Fin" más lejano de entre
-- los periodos activos ahora mismo; si alguno de los activos es indefinido, el resultado es
-- indefinido.
--
-- Requiere que 079 ya esté aplicado.

CREATE TABLE "TConfiguracionPeriodosGratuitos" (
    "IdConfiguracionPeriodoGratuito" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Inicio" timestamptz NOT NULL,
    "Fin" timestamptz NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE "TSistemaUsuarioPeriodosGratuitos" (
    "IdSistemaUsuarioPeriodoGratuito" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Inicio" timestamptz NOT NULL,
    "Fin" timestamptz NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaUsuarioPeriodosGratuitos"
    ADD CONSTRAINT "FK_TSistemaUsuarioPeriodosGratuitos_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaUsuarioPeriodosGratuitos_IdSistemaUsuario"
    ON "TSistemaUsuarioPeriodosGratuitos" ("IdSistemaUsuario");

ALTER TABLE "TConfiguracionPeriodosGratuitos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TSistemaUsuarioPeriodosGratuitos" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionPeriodosGratuitos"
    BEFORE UPDATE ON "TConfiguracionPeriodosGratuitos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TSistemaUsuarioPeriodosGratuitos"
    BEFORE UPDATE ON "TSistemaUsuarioPeriodosGratuitos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Lectura: cualquier autenticado ve los generales (son iguales para todos); de los propios de
-- cliente, cada uno ve los suyos (o ADMIN, todos). Mutación (alta/edición/baja) solo ADMIN en
-- los dos casos: por ahora el periodo gratuito lo regala el ADMIN, no lo elige el cliente.
CREATE POLICY "select_autenticado_TConfiguracionPeriodosGratuitos" ON "TConfiguracionPeriodosGratuitos"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionPeriodosGratuitos" ON "TConfiguracionPeriodosGratuitos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "select_propio_o_admin_TSistemaUsuarioPeriodosGratuitos" ON "TSistemaUsuarioPeriodosGratuitos"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TSistemaUsuarios" u
            WHERE u."IdSistemaUsuario" = "TSistemaUsuarioPeriodosGratuitos"."IdSistemaUsuario"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "mutacion_admin_TSistemaUsuarioPeriodosGratuitos" ON "TSistemaUsuarioPeriodosGratuitos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- Migra cualquier periodo ya cargado con el modelo anterior (077/078) antes de borrar esas
-- columnas.
-- =====================================================================
INSERT INTO "TConfiguracionPeriodosGratuitos" ("Inicio", "Fin")
SELECT "PeriodoGratuitoInicio", "PeriodoGratuitoFin"
FROM "TConfiguracionGlobal"
WHERE "PeriodoGratuitoInicio" IS NOT NULL;

INSERT INTO "TSistemaUsuarioPeriodosGratuitos" ("IdSistemaUsuario", "Inicio", "Fin")
SELECT "IdSistemaUsuario", "PeriodoGratuitoInicio", "PeriodoGratuitoFin"
FROM "TSistemaUsuarios"
WHERE "PeriodoGratuitoInicio" IS NOT NULL;

ALTER TABLE "TConfiguracionGlobal"
    DROP COLUMN "PeriodoGratuitoInicio",
    DROP COLUMN "PeriodoGratuitoFin";

ALTER TABLE "TSistemaUsuarios"
    DROP COLUMN "PeriodoGratuitoInicio",
    DROP COLUMN "PeriodoGratuitoFin";

DROP FUNCTION IF EXISTS "FSistemaPeriodoGratuitoAplicable"(uuid);

-- =====================================================================
-- ¿Hay al menos un periodo (general o propio del cliente) activo ahora mismo?
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaClienteEnPeriodoGratuito"(p_id_sistema_usuario uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM "TConfiguracionPeriodosGratuitos"
        WHERE now() >= "Inicio" AND ("Fin" IS NULL OR now() <= "Fin")
    ) OR EXISTS (
        SELECT 1 FROM "TSistemaUsuarioPeriodosGratuitos"
        WHERE "IdSistemaUsuario" = p_id_sistema_usuario
          AND now() >= "Inicio" AND ("Fin" IS NULL OR now() <= "Fin")
    );
$$;

-- Fecha de fin "efectiva" a mostrar (el más lejano de entre los periodos activos ahora mismo;
-- NULL si alguno de los activos es indefinido, o si no hay ninguno activo).
CREATE OR REPLACE FUNCTION "FSistemaPeriodoGratuitoFinEfectivo"(p_id_sistema_usuario uuid)
RETURNS timestamptz
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_hay_indefinido boolean;
    v_fin_max timestamptz;
BEGIN
    SELECT bool_or("Fin" IS NULL), max("Fin")
        INTO v_hay_indefinido, v_fin_max
        FROM (
            SELECT "Fin" FROM "TConfiguracionPeriodosGratuitos"
            WHERE now() >= "Inicio" AND ("Fin" IS NULL OR now() <= "Fin")
            UNION ALL
            SELECT "Fin" FROM "TSistemaUsuarioPeriodosGratuitos"
            WHERE "IdSistemaUsuario" = p_id_sistema_usuario
              AND now() >= "Inicio" AND ("Fin" IS NULL OR now() <= "Fin")
        ) activos;

    IF v_hay_indefinido THEN
        RETURN NULL;
    END IF;

    RETURN v_fin_max;
END;
$$;

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
BEGIN
    SELECT "IdSistemaUsuario", "PlanPagado"
        INTO v_id_sistema_usuario, v_pagado
        FROM "TSistemaUsuarios"
        WHERE "IdAuthSupabase" = auth.uid();

    IF v_id_sistema_usuario IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY SELECT
        v_pagado,
        "FSistemaClienteEnPeriodoGratuito"(v_id_sistema_usuario),
        "FSistemaPeriodoGratuitoFinEfectivo"(v_id_sistema_usuario);
END;
$$;
