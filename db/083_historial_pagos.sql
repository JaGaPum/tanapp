-- =====================================================================
-- 083 - Historial de pagos (sustituye el interruptor "PlanPagado")
-- =====================================================================
-- "PlanPagado" (076) era un simple sí/no que el ADMIN marcaba a mano, sin fecha: no dejaba
-- constancia de cuándo se pagó ni hasta cuándo cubre ese pago. Se sustituye por un historial
-- real: cada fila es un pago, con su fecha y los 30 días naturales que cubre a partir de ella
-- (criterio simple y predecible, sin las irregularidades de "un mes" en el calendario -28 a 31
-- días según el mes-). Un cliente está "al día" si HOY cae dentro de la cobertura de CUALQUIERA
-- de sus pagos (normalmente el último, pero no hace falta que "gane" uno solo: mismo criterio ya
-- usado para los periodos gratuitos, 080).
--
-- "FechaFinCobertura" no la manda quien inserta/edita: la calcula siempre un trigger a partir de
-- "FechaPago", para que los 30 días sean una regla del sistema y no algo que dependa de que la
-- app haga bien la cuenta.
--
-- Requiere que 076 ya esté aplicado.

CREATE TABLE "TSistemaUsuarioPagos" (
    "IdSistemaUsuarioPago" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "FechaPago" timestamptz NOT NULL,
    "FechaFinCobertura" timestamptz NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaUsuarioPagos"
    ADD CONSTRAINT "FK_TSistemaUsuarioPagos_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaUsuarioPagos_IdSistemaUsuario" ON "TSistemaUsuarioPagos" ("IdSistemaUsuario");

ALTER TABLE "TSistemaUsuarioPagos" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TSistemaUsuarioPagos"
    BEFORE UPDATE ON "TSistemaUsuarioPagos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- "FechaFinCobertura" es siempre "FechaPago" + 30 días, la mande quien la mande: así no hay
-- forma de guardar un pago con una cobertura distinta a la regla de negocio.
CREATE OR REPLACE FUNCTION "FSistemaCalcularFinCoberturaPago"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."FechaFinCobertura" := NEW."FechaPago" + interval '30 days';
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_CalcularFinCobertura_TSistemaUsuarioPagos"
    BEFORE INSERT OR UPDATE ON "TSistemaUsuarioPagos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaCalcularFinCoberturaPago"();

-- Mismo patrón que "select_propio_o_admin_TSistemaUsuarioPeriodosGratuitos" (080): cada cliente
-- ve su propio historial (o ADMIN, el de cualquiera); solo ADMIN registra/corrige pagos.
CREATE POLICY "select_propio_o_admin_TSistemaUsuarioPagos" ON "TSistemaUsuarioPagos"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TSistemaUsuarios" u
            WHERE u."IdSistemaUsuario" = "TSistemaUsuarioPagos"."IdSistemaUsuario"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "mutacion_admin_TSistemaUsuarioPagos" ON "TSistemaUsuarioPagos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- Migra el estado actual: todo cliente con "PlanPagado" true recibe un pago de hoy (cubre los
-- próximos 30 días), para no cortarle de golpe al aplicar esta migración.
-- =====================================================================
INSERT INTO "TSistemaUsuarioPagos" ("IdSistemaUsuario", "FechaPago", "FechaFinCobertura")
SELECT "IdSistemaUsuario", now(), now() + interval '30 days'
FROM "TSistemaUsuarios"
WHERE "PlanPagado" = true;

ALTER TABLE "TSistemaUsuarios"
    DROP COLUMN "PlanPagado";

-- ¿Tiene este cliente hoy algún pago vigente (su fecha de cobertura todavía no ha pasado)?
CREATE OR REPLACE FUNCTION "FSistemaClienteTienePagoVigente"(p_id_sistema_usuario uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM "TSistemaUsuarioPagos"
        WHERE "IdSistemaUsuario" = p_id_sistema_usuario
          AND now() >= "FechaPago" AND now() <= "FechaFinCobertura"
    );
$$;

-- Los triggers de bloqueo (076/077) pasan a comprobar el historial de pagos en vez de la
-- columna "PlanPagado", que ya no existe.
CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoPorSede"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sistema_usuario uuid;
BEGIN
    SELECT u."IdSistemaUsuario"
        INTO v_id_sistema_usuario
        FROM "TClienteSedes" s
        JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
        WHERE s."IdClienteSede" = NEW."IdClienteSede";

    IF NOT "FSistemaClienteTienePagoVigente"(v_id_sistema_usuario)
        AND NOT "FSistemaClienteEnPeriodoGratuito"(v_id_sistema_usuario) THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION "FSistemaValidarPlanPagadoTClienteSedes"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT "FSistemaClienteTienePagoVigente"(NEW."IdSistemaUsuario")
        AND NOT "FSistemaClienteEnPeriodoGratuito"(NEW."IdSistemaUsuario") THEN
        RAISE EXCEPTION 'Tu plan de suscripción no está al día. Contacta con soporte para regularizarlo.';
    END IF;

    RETURN NEW;
END;
$$;

-- La RPC de autoservicio (078) calcula ahora "PlanPagado" con el historial de pagos.
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
BEGIN
    SELECT "IdSistemaUsuario"
        INTO v_id_sistema_usuario
        FROM "TSistemaUsuarios"
        WHERE "IdAuthSupabase" = auth.uid();

    IF v_id_sistema_usuario IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY SELECT
        "FSistemaClienteTienePagoVigente"(v_id_sistema_usuario),
        "FSistemaClienteEnPeriodoGratuito"(v_id_sistema_usuario),
        "FSistemaPeriodoGratuitoFinEfectivo"(v_id_sistema_usuario);
END;
$$;
