-- =====================================================================
-- 004 - Renombrado de TClientesSolicitudes a TClienteSolicitudes (singular),
--        validación de email por el admin y borrado de usuarios/solicitudes
-- =====================================================================
-- Requiere que 003 ya esté aplicado.

-- =====================================================================
-- 1. Renombrado: el módulo va siempre en singular -> TClienteSolicitudes
-- =====================================================================
ALTER TABLE "TClientesSolicitudes" RENAME TO "TClienteSolicitudes";

ALTER TABLE "TClienteSolicitudes"
    RENAME CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioResolucion"
        TO "FK_TClienteSolicitudes_IdSistemaUsuarioResolucion";
ALTER TABLE "TClienteSolicitudes"
    RENAME CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioAlta"
        TO "FK_TClienteSolicitudes_IdSistemaUsuarioAlta";
ALTER TABLE "TClienteSolicitudes"
    RENAME CONSTRAINT "FK_TClientesSolicitudes_IdSistemaUsuarioModificacion"
        TO "FK_TClienteSolicitudes_IdSistemaUsuarioModificacion";

ALTER INDEX "IX_TClientesSolicitudes_Estado" RENAME TO "IX_TClienteSolicitudes_Estado";
ALTER INDEX "IX_TClientesSolicitudes_IdSistemaUsuarioResolucion"
    RENAME TO "IX_TClienteSolicitudes_IdSistemaUsuarioResolucion";

ALTER TRIGGER "trigger_FechaModificacion_TClientesSolicitudes" ON "TClienteSolicitudes"
    RENAME TO "trigger_FechaModificacion_TClienteSolicitudes";

ALTER POLICY "insert_publico_TClientesSolicitudes" ON "TClienteSolicitudes"
    RENAME TO "insert_publico_TClienteSolicitudes";
ALTER POLICY "select_admin_TClientesSolicitudes" ON "TClienteSolicitudes"
    RENAME TO "select_admin_TClienteSolicitudes";
ALTER POLICY "update_admin_TClientesSolicitudes" ON "TClienteSolicitudes"
    RENAME TO "update_admin_TClienteSolicitudes";

-- =====================================================================
-- 2. Borrado: ADMIN puede eliminar solicitudes de clientes
-- =====================================================================
CREATE POLICY "delete_admin_TClienteSolicitudes" ON "TClienteSolicitudes"
    FOR DELETE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- 3. Borrado: ADMIN puede eliminar usuarios (perfil de la app)
-- =====================================================================
CREATE POLICY "delete_admin_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR DELETE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- 4. Validación de email: columna espejo + sincronización + RPC de admin
-- =====================================================================
ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "EmailConfirmado" boolean NOT NULL DEFAULT false;

-- Mantiene "EmailConfirmado" sincronizado con auth.users.email_confirmed_at
-- (se actualizará solo cuando el envío de correo esté activo y el usuario confirme).
CREATE OR REPLACE FUNCTION "FSistemaSyncEmailConfirmado"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE "TSistemaUsuarios"
    SET "EmailConfirmado" = (NEW.email_confirmed_at IS NOT NULL)
    WHERE "IdAuthSupabase" = NEW.id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS "trigger_FSistemaSyncEmailConfirmado" ON auth.users;
CREATE TRIGGER "trigger_FSistemaSyncEmailConfirmado"
    AFTER UPDATE OF email_confirmed_at ON auth.users
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSyncEmailConfirmado"();

-- Permite al ADMIN dar por validado a un usuario manualmente mientras el envío
-- de correo no esté activo (equivale a que hubiese confirmado el código recibido).
CREATE OR REPLACE FUNCTION "FSistemaAdminConfirmarEmail"(id_sistema_usuario uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT "FSistemaUsuarioTieneRol"('ADMIN') THEN
        RAISE EXCEPTION 'No autorizado';
    END IF;

    UPDATE auth.users
    SET email_confirmed_at = COALESCE(email_confirmed_at, now())
    WHERE id = (
        SELECT "IdAuthSupabase" FROM "TSistemaUsuarios" WHERE "IdSistemaUsuario" = id_sistema_usuario
    );

    UPDATE "TSistemaUsuarios"
    SET "EmailConfirmado" = true
    WHERE "IdSistemaUsuario" = id_sistema_usuario;
END;
$$;

GRANT EXECUTE ON FUNCTION "FSistemaAdminConfirmarEmail"(uuid) TO authenticated;
