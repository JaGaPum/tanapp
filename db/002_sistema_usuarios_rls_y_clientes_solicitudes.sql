-- =====================================================================
-- 002 - RLS reales para Sistema>Usuarios + alta del módulo Clientes
--        (tabla de solicitudes de alta de cliente)
-- =====================================================================
-- Requiere que 001 (TSistemaUsuarios, TSistemaRoles, TSistemaUsuariosRoles,
-- TSistemaIdiomas con RLS deny_all) ya esté aplicado.

-- =====================================================================
-- 1. Tabla nueva: TClientesSolicitudes (primera pieza del módulo Clientes)
-- =====================================================================
CREATE TABLE "TClientesSolicitudes" (
    "IdClientesSolicitud" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "RazonSocial" varchar(200) NOT NULL,
    "NifCif" varchar(20) NOT NULL,
    "NombreContacto" varchar(200) NOT NULL,
    "EmailContacto" varchar(255) NOT NULL,
    "TelefonoContacto" varchar(50) NOT NULL,
    "Localidad" varchar(150) NULL,
    "Provincia" varchar(150) NULL,
    "Observaciones" text NULL,
    "Estado" varchar(20) NOT NULL DEFAULT 'PENDIENTE'
        CHECK ("Estado" IN ('PENDIENTE', 'APROBADA', 'RECHAZADA')),
    "ObservacionesResolucion" text NULL,
    "FechaResolucion" timestamptz NULL,
    "IdSistemaUsuarioResolucion" uuid NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "IdSistemaUsuarioAlta" uuid NULL,
    "FechaModificacion" timestamptz NOT NULL DEFAULT now(),
    "IdSistemaUsuarioModificacion" uuid NULL
);

ALTER TABLE "TClientesSolicitudes"
    ADD CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioResolucion"
        FOREIGN KEY ("IdSistemaUsuarioResolucion")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE SET NULL,
    ADD CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioAlta"
        FOREIGN KEY ("IdSistemaUsuarioAlta")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE SET NULL,
    ADD CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioModificacion"
        FOREIGN KEY ("IdSistemaUsuarioModificacion")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE SET NULL;

CREATE INDEX "IX_TClientesSolicitudes_Estado" ON "TClientesSolicitudes" ("Estado");
CREATE INDEX "IX_TClientesSolicitudes_IdSistemaUsuarioResolucion"
    ON "TClientesSolicitudes" ("IdSistemaUsuarioResolucion");

ALTER TABLE "TClientesSolicitudes" ENABLE ROW LEVEL SECURITY;

-- =====================================================================
-- 2. Función auxiliar de rol (evita recursión de RLS al ser SECURITY DEFINER)
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaUsuarioTieneRol"(codigo_rol text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "TSistemaUsuarios" u
        JOIN "TSistemaUsuariosRoles" ur ON ur."IdSistemaUsuario" = u."IdSistemaUsuario"
        JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
        WHERE u."IdAuthSupabase" = auth.uid()
          AND r."Codigo" = codigo_rol
    );
$$;

GRANT EXECUTE ON FUNCTION "FSistemaUsuarioTieneRol"(text) TO authenticated;

-- =====================================================================
-- 3. Trigger de auto-alta: crea la fila en TSistemaUsuarios cuando
--    Supabase Auth crea un usuario (autorregistro de usuario ordinario)
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
    INSERT INTO "TSistemaUsuarios" ("IdAuthSupabase", "Email", "Nombre", "Telefono")
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'nombre', NEW.email),
        NEW.raw_user_meta_data ->> 'telefono'
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

CREATE TRIGGER "trigger_FSistemaHandleNewAuthUser"
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION "FSistemaHandleNewAuthUser"();

-- NOTA: este trigger asigna USUARIO_ORDINARIO a *cualquier* alta en auth.users.
-- El día que se cree el flujo de alta de empleados de clientes (Admin API /
-- Edge Function), habrá que revisar este trigger para no asignarles ese rol
-- por defecto (o quitárselo justo después desde esa Edge Function).

-- =====================================================================
-- 4. Trigger genérico para mantener FechaModificacion sin depender del cliente
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaSetFechaModificacion"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."FechaModificacion" := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_FechaModificacion_TSistemaUsuarios"
    BEFORE UPDATE ON "TSistemaUsuarios"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TSistemaRoles"
    BEFORE UPDATE ON "TSistemaRoles"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TSistemaUsuariosRoles"
    BEFORE UPDATE ON "TSistemaUsuariosRoles"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TSistemaIdiomas"
    BEFORE UPDATE ON "TSistemaIdiomas"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TClientesSolicitudes"
    BEFORE UPDATE ON "TClientesSolicitudes"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- =====================================================================
-- 5. RLS reales: sustituyen las policies deny_all de 001
-- =====================================================================

-- TSistemaUsuarios: cada usuario ve/edita su propia fila; ADMIN ve/edita todas
DROP POLICY IF EXISTS "deny_all_TSistemaUsuarios" ON "TSistemaUsuarios";

CREATE POLICY "select_propio_o_admin_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR SELECT TO authenticated
    USING ("IdAuthSupabase" = auth.uid() OR "FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "update_propio_o_admin_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR UPDATE TO authenticated
    USING ("IdAuthSupabase" = auth.uid() OR "FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("IdAuthSupabase" = auth.uid() OR "FSistemaUsuarioTieneRol"('ADMIN'));

-- TSistemaRoles: catálogo de lectura para cualquier autenticado; mutación solo ADMIN
DROP POLICY IF EXISTS "deny_all_TSistemaRoles" ON "TSistemaRoles";

CREATE POLICY "select_catalogo_TSistemaRoles" ON "TSistemaRoles"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TSistemaRoles" ON "TSistemaRoles"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- TSistemaIdiomas: mismo patrón que TSistemaRoles
DROP POLICY IF EXISTS "deny_all_TSistemaIdiomas" ON "TSistemaIdiomas";

CREATE POLICY "select_catalogo_TSistemaIdiomas" ON "TSistemaIdiomas"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TSistemaIdiomas" ON "TSistemaIdiomas"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- TSistemaUsuariosRoles: cada usuario ve sus propios roles; ADMIN gestiona todos
DROP POLICY IF EXISTS "deny_all_TSistemaUsuariosRoles" ON "TSistemaUsuariosRoles";

CREATE POLICY "select_propio_o_admin_TSistemaUsuariosRoles" ON "TSistemaUsuariosRoles"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_admin_TSistemaUsuariosRoles" ON "TSistemaUsuariosRoles"
    FOR INSERT TO authenticated
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "delete_admin_TSistemaUsuariosRoles" ON "TSistemaUsuariosRoles"
    FOR DELETE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));

-- TClientesSolicitudes: alta pública (sin auth), solo ADMIN puede ver/resolver
CREATE POLICY "insert_publico_TClientesSolicitudes" ON "TClientesSolicitudes"
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

CREATE POLICY "select_admin_TClientesSolicitudes" ON "TClientesSolicitudes"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "update_admin_TClientesSolicitudes" ON "TClientesSolicitudes"
    FOR UPDATE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));
