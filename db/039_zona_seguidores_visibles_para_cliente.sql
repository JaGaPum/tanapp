-- =====================================================================
-- 039 - El cliente dueño de una sede necesita poder ver (contar) cuánta gente sigue la zona
--        de esa sede, para mostrarlo en su Panel de Datos. Mismo criterio que 018 con
--        "TClienteSeguimientos": policy adicional y permisiva, se suma a
--        "mutacion_propia_TSistemaUsuarioZonas" (038), no la sustituye.
-- =====================================================================
-- Requiere que 038 ya esté aplicado.

CREATE POLICY "select_propietario_sede_TSistemaUsuarioZonas" ON "TSistemaUsuarioZonas"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."Concello" = "TSistemaUsuarioZonas"."Concello"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );
