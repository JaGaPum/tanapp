-- =====================================================================
-- 029 - El administrador puede activar/desactivar la importación automática de un cliente
-- =====================================================================
-- TClienteImportacionWeb (027) solo tenía policies "propio" (el cliente gestiona su propia
-- fila). Se añaden policies de ADMIN, mismo patrón que TSistemaTerminos en 026, para que un
-- administrador pueda consultar y activar/desactivar la configuración de cualquier cliente
-- desde la ficha de usuario.
-- Requiere que 028 ya esté aplicado.

CREATE POLICY "select_admin_TClienteImportacionWeb" ON "TClienteImportacionWeb"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "update_admin_TClienteImportacionWeb" ON "TClienteImportacionWeb"
    FOR UPDATE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));
