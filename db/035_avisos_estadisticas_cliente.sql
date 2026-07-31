-- =====================================================================
-- 035 - El cliente puede leer los destinatarios de sus propios avisos (para estadísticas)
-- =====================================================================
-- "TClienteAvisosDestinatarios" (031) solo tenía policy de SELECT para el propio destinatario
-- (el seguidor viendo su buzón). Para que el cliente que envió el aviso pueda ver cuántos
-- seguidores lo recibieron y cuántos lo han leído (Panel de Datos), hace falta una policy
-- adicional para el remitente (o ADMIN). Las policies permisivas de SELECT se combinan con OR,
-- así que esto no cambia nada de lo que ya podía ver el propio destinatario.
-- Requiere que 034 ya esté aplicado.

CREATE POLICY "select_propio_cliente_TClienteAvisosDestinatarios" ON "TClienteAvisosDestinatarios"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1
            FROM "TClienteAvisos" a
            JOIN "TClienteSedes" s ON s."IdClienteSede" = a."IdClienteSede"
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE a."IdClienteAviso" = "TClienteAvisosDestinatarios"."IdClienteAviso"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );
