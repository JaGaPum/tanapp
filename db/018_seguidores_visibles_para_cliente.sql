-- =====================================================================
-- 018 - El cliente dueño de una sede necesita poder ver (contar) quién le sigue, para el
--        número de seguidores en su Panel de Datos. Hoy "select_propio_o_admin_TClienteSeguimientos"
--        (012) solo deja verlo al propio seguidor o a ADMIN. Policy adicional y permisiva: se
--        suma a esa, no la sustituye.
-- =====================================================================
-- Requiere que 017 ya esté aplicado.

CREATE POLICY "select_propietario_sede_TClienteSeguimientos" ON "TClienteSeguimientos"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClienteSeguimientos"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );
