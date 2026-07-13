-- =====================================================================
-- 003 - Sistema de sesiones (recordarme + caducidad de 30 min),
--        datos personales ampliados y avatar de usuario
-- =====================================================================
-- Requiere que 002 (TSistemaUsuarios, FSistemaUsuarioTieneRol,
-- FSistemaSetFechaModificacion, FSistemaHandleNewAuthUser) ya esté aplicado.

-- =====================================================================
-- 1. Tabla nueva: TSistemaSesiones
-- =====================================================================
CREATE TABLE "TSistemaSesiones" (
    "IdSistemaSesion" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "FechaInicio" timestamptz NOT NULL DEFAULT now(),
    "FechaUltimoAcceso" timestamptz NOT NULL DEFAULT now(),
    "FechaFin" timestamptz NULL,
    "Recordar" boolean NOT NULL DEFAULT false,
    "Estado" varchar(20) NOT NULL DEFAULT 'ABIERTA'
        CHECK ("Estado" IN ('ABIERTA', 'CERRADA')),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaSesiones"
    ADD CONSTRAINT "FK_TSistemaSesiones_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaSesiones_IdSistemaUsuario" ON "TSistemaSesiones" ("IdSistemaUsuario");

-- Acelera la búsqueda de "última sesión abierta de un usuario" (bootstrap + histórico admin)
CREATE INDEX "IX_TSistemaSesiones_Abiertas"
    ON "TSistemaSesiones" ("IdSistemaUsuario", "FechaUltimoAcceso" DESC)
    WHERE "Estado" = 'ABIERTA';

ALTER TABLE "TSistemaSesiones" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TSistemaSesiones"
    BEFORE UPDATE ON "TSistemaSesiones"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Cada usuario ve/gestiona sus propias sesiones; ADMIN ve/gestiona todas (histórico)
CREATE POLICY "select_propia_o_admin_TSistemaSesiones" ON "TSistemaSesiones"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propia_TSistemaSesiones" ON "TSistemaSesiones"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propia_o_admin_TSistemaSesiones" ON "TSistemaSesiones"
    FOR UPDATE TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Sin policy de DELETE: las sesiones son histórico de auditoría, no se borran.

-- =====================================================================
-- 2. TSistemaUsuarios: datos personales ampliados + avatar
-- =====================================================================
ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "Apellido1" varchar(150) NULL,
    ADD COLUMN "Apellido2" varchar(150) NULL,
    ADD COLUMN "Concello" varchar(150) NULL,
    ADD COLUMN "Provincia" varchar(150) NULL,
    ADD COLUMN "FotoUrl" text NULL;

-- NOTA: se mantienen nullable a nivel de BD para no romper las filas existentes.
-- "Apellido1 obligatorio" se exige solo en los formularios de Flutter.

-- =====================================================================
-- 3. Alta automática: propaga los nuevos campos desde raw_user_meta_data
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaHandleNewAuthUser"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    nuevo_id uuid;
    id_rol_ordinario uuid;
BEGIN
    INSERT INTO "TSistemaUsuarios"
        ("IdAuthSupabase", "Email", "Nombre", "Apellido1", "Apellido2", "Telefono", "Concello", "Provincia")
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'nombre', NEW.email),
        NEW.raw_user_meta_data ->> 'apellido1',
        NEW.raw_user_meta_data ->> 'apellido2',
        NEW.raw_user_meta_data ->> 'telefono',
        NEW.raw_user_meta_data ->> 'concello',
        NEW.raw_user_meta_data ->> 'provincia'
    )
    RETURNING "IdSistemaUsuario" INTO nuevo_id;

    SELECT "IdSistemaRol" INTO id_rol_ordinario
    FROM "TSistemaRoles"
    WHERE "Codigo" = 'USUARIO_ORDINARIO';

    IF id_rol_ordinario IS NOT NULL THEN
        INSERT INTO "TSistemaUsuariosRoles" ("IdSistemaUsuario", "IdSistemaRol")
        VALUES (nuevo_id, id_rol_ordinario);
    END IF;

    RETURN NEW;
END;
$$;

-- =====================================================================
-- 4. Storage: bucket de avatares + RLS (público en lectura, propio en escritura)
-- =====================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatares', 'avatares', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "select_publico_avatares" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'avatares');

CREATE POLICY "insert_propio_avatares" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "update_propio_avatares" ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "delete_propio_avatares" ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);
