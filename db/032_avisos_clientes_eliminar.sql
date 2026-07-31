-- =====================================================================
-- 032 - El seguidor puede eliminar avisos de su propia bandeja
-- =====================================================================
-- TClienteAvisosDestinatarios (031) solo tenía policies de SELECT y UPDATE (para marcar
-- "Leido"): faltaba DELETE para que el usuario pueda quitarse avisos de su bandeja (uno,
-- varios o todos). Borrar su fila de destinatario no toca "TClienteAvisos" (el contenido, que
-- es del cliente) ni las filas de otros destinatarios.
-- Requiere que 031 ya esté aplicado.

CREATE POLICY "delete_propio_TClienteAvisosDestinatarios" ON "TClienteAvisosDestinatarios"
    FOR DELETE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );
