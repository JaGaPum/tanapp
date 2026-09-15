-- =====================================================================
-- 075 - Planes de suscripción (Local/Multisede/Gran Grupo) y límite de sedes
-- =====================================================================
-- Tres planes fijos que solo se diferencian por el número máximo de sedes: el admin puede
-- editar el precio y el límite de cada uno desde Configuración > Planes de suscripción, pero no
-- crear, borrar ni renombrar planes (no se ha pedido esa flexibilidad).
--
-- El pago en sí queda fuera de esta migración -se aborda más adelante, cuando el cliente pueda
-- elegir y pagar su propio plan-: por ahora el plan de cada cliente lo asigna el ADMIN a mano en
-- su ficha, y mientras no se le asigne ninguno se le trata como "Local" (1 sede).
--
-- Requiere que 010 (TConfiguracionClienteTipos, mismo patrón de tabla de catálogo) y 046
-- (FSistemaUsuarioTieneRol) ya estén aplicados.

-- =====================================================================
-- 1. Tabla: TConfiguracionPlanesSuscripcion
-- =====================================================================
CREATE TABLE "TConfiguracionPlanesSuscripcion" (
    "IdConfiguracionPlanSuscripcion" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Nombre" varchar(100) NOT NULL,
    "PrecioMensual" numeric(10, 2) NOT NULL,
    "MaxSedes" integer NOT NULL CHECK ("MaxSedes" > 0),
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TConfiguracionPlanesSuscripcion_Nombre" ON "TConfiguracionPlanesSuscripcion" ("Nombre");

ALTER TABLE "TConfiguracionPlanesSuscripcion" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionPlanesSuscripcion"
    BEFORE UPDATE ON "TConfiguracionPlanesSuscripcion"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Lectura para cualquier autenticado (lo usa el desplegable de la ficha de Usuario y, más
-- adelante, la propia pantalla del cliente); mutación (solo precio/límite, nunca alta/baja desde
-- la app) restringida a ADMIN.
CREATE POLICY "select_autenticado_TConfiguracionPlanesSuscripcion" ON "TConfiguracionPlanesSuscripcion"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionPlanesSuscripcion" ON "TConfiguracionPlanesSuscripcion"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

INSERT INTO "TConfiguracionPlanesSuscripcion" ("Nombre", "PrecioMensual", "MaxSedes") VALUES
    ('Local', 29.00, 1),
    ('Multisede', 59.00, 4),
    ('Gran Grupo', 99.00, 10)
ON CONFLICT ("Nombre") DO NOTHING;

-- =====================================================================
-- 2. TSistemaUsuarios: plan asignado (editable en su ficha, solo por ADMIN por ahora)
-- =====================================================================
ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "IdConfiguracionPlanSuscripcion" uuid NULL;

ALTER TABLE "TSistemaUsuarios"
    ADD CONSTRAINT "FK_TSistemaUsuarios_IdConfiguracionPlanSuscripcion"
        FOREIGN KEY ("IdConfiguracionPlanSuscripcion")
        REFERENCES "TConfiguracionPlanesSuscripcion" ("IdConfiguracionPlanSuscripcion")
        ON DELETE SET NULL;

-- Backfill: todo cliente (rol CLIENTE) que todavía no tenga plan queda en "Local", para no
-- romper ninguna cuenta ya existente hoy.
UPDATE "TSistemaUsuarios" u
SET "IdConfiguracionPlanSuscripcion" = (
    SELECT "IdConfiguracionPlanSuscripcion" FROM "TConfiguracionPlanesSuscripcion" WHERE "Nombre" = 'Local'
)
WHERE u."IdConfiguracionPlanSuscripcion" IS NULL
  AND EXISTS (
      SELECT 1
      FROM "TSistemaUsuariosRoles" r
      JOIN "TSistemaRoles" ro ON ro."IdSistemaRol" = r."IdSistemaRol"
      WHERE r."IdSistemaUsuario" = u."IdSistemaUsuario" AND ro."Codigo" = 'CLIENTE'
  );

-- =====================================================================
-- 3. Límite de sedes: se aplica ya, no es solo informativo
-- =====================================================================
-- Trigger de solo lectura sobre datos ya visibles para quien inserta (su propia fila de
-- TSistemaUsuarios/TConfiguracionPlanesSuscripcion, o cualquier cliente si quien inserta es
-- ADMIN): no hace falta SECURITY DEFINER, igual que el resto de triggers de validación de esta
-- app que no cruzan un límite de RLS.
CREATE OR REPLACE FUNCTION "FSistemaValidarLimiteSedes"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_sedes integer;
    v_actuales integer;
BEGIN
    SELECT p."MaxSedes" INTO v_max_sedes
    FROM "TSistemaUsuarios" u
    JOIN "TConfiguracionPlanesSuscripcion" p
        ON p."IdConfiguracionPlanSuscripcion" = u."IdConfiguracionPlanSuscripcion"
    WHERE u."IdSistemaUsuario" = NEW."IdSistemaUsuario";

    -- Sin plan asignado (no debería pasar tras el backfill y la asignación automática al
    -- aprobar una solicitud, pero por si acaso): no bloquea, se deja para cuando se le asigne uno.
    IF v_max_sedes IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT count(*) INTO v_actuales
    FROM "TClienteSedes"
    WHERE "IdSistemaUsuario" = NEW."IdSistemaUsuario";

    IF v_actuales >= v_max_sedes THEN
        RAISE EXCEPTION 'Has llegado al máximo de % sede(s) de tu plan actual. Contacta con soporte para ampliar tu plan.', v_max_sedes;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_ValidarLimiteSedes_TClienteSedes"
    BEFORE INSERT ON "TClienteSedes"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarLimiteSedes"();
