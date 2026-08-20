-- =====================================================================
-- 054 - ADMIN puede ver las aceptaciones de términos de cualquier usuario
-- =====================================================================
-- "select_propio_TSistemaTerminosAceptaciones" (026) solo dejaba ver a cada usuario sus propias
-- aceptaciones, sin excepción para ADMIN. Al consultar la ficha de otro usuario (ver
-- "terminosPendientesDeUsuarioProvider" en la app), la RLS filtraba todas las filas y el admin
-- veía "pendiente" aunque el usuario sí hubiese aceptado. Se añade la misma excepción que ya
-- tienen el resto de tablas de la app (p. ej. condolencias, sesiones...).

DROP POLICY "select_propio_TSistemaTerminosAceptaciones" ON "TSistemaTerminosAceptaciones";

CREATE POLICY "select_propio_o_admin_TSistemaTerminosAceptaciones" ON "TSistemaTerminosAceptaciones"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );
