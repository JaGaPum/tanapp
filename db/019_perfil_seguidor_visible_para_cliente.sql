-- =====================================================================
-- 019 - Para desglosar los seguidores de una sede por el concello del propio seguidor (no el
--        de la sede), el cliente necesita poder leer ese dato del perfil del seguidor. Hoy
--        "select_propio_o_admin_TSistemaUsuarios" y "select_clientes_activos_TSistemaUsuarios"
--        (002, 012) no cubren este caso: un usuario ordinario que solo sigue no es ni el
--        propio usuario que consulta ni un cliente activo, así que no es visible para nadie
--        más. Policy adicional y permisiva, acotada a quien de verdad le sigue: se suma a las
--        anteriores, no las sustituye. La RLS solo abre la FILA; qué columnas se leen lo decide
--        cada consulta (la app solo pide "Concello").
-- =====================================================================
-- Requiere que 018 ya esté aplicado.

CREATE POLICY "select_seguidor_de_mi_sede_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM "TClienteSeguimientos" f
            JOIN "TClienteSedes" s ON s."IdClienteSede" = f."IdClienteSede"
            JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE f."IdSistemaUsuario" = "TSistemaUsuarios"."IdSistemaUsuario"
              AND propietario."IdAuthSupabase" = auth.uid()
        )
    );
