-- =====================================================================
-- Utilidad: borra TODOS los usuarios y sus datos relacionados, salvo quienes
-- tengan el rol ADMIN.
--
-- No es una migración (no cambia el esquema): es un script para ejecutar a mano
-- desde el SQL Editor de Supabase, pensado para vaciar datos de prueba.
--
-- IRREVERSIBLE. Borra, para cada usuario no-ADMIN: su ficha (TSistemaUsuarios),
-- roles, sedes de cliente, publicaciones, seguimientos, zonas seguidas, avisos,
-- condolencias, sesiones, dispositivos push, configuración de importación web,
-- propuestas de importación, logs de suplantación y su cuenta de Supabase Auth
-- (auth.users) — todo lo que cuelga de "TSistemaUsuarios" vía ON DELETE CASCADE,
-- igual que ya hace UsuariosRepository.eliminarUsuario() para un usuario suelto,
-- más el borrado de auth.users que ese método no hace.
--
-- PASO 1 (hazlo antes, como consulta aparte): revisa quién se va a borrar.
--
--   SELECT "IdSistemaUsuario", "Email", "Nombre"
--   FROM "TSistemaUsuarios" u
--   WHERE NOT EXISTS (
--       SELECT 1 FROM "TSistemaUsuariosRoles" ur
--       JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
--       WHERE ur."IdSistemaUsuario" = u."IdSistemaUsuario" AND r."Codigo" = 'ADMIN'
--   );
--
-- PASO 2: si la lista de arriba es la que esperabas, ejecuta TODO lo de abajo
-- de una sola vez (un único "Run" del SQL Editor). El BEGIN/COMMIT sigue yendo
-- dentro de una transacción para que, si algo falla a mitad (p. ej. una tabla con
-- una FK sin CASCADE que aún no contemplásemos), no se aplique nada; pero al ir
-- el COMMIT en la misma ejecución, esta vez sí queda guardado de verdad (antes,
-- al dejarlo comentado para confirmarlo aparte, Supabase cierra la conexión al
-- terminar cada "Run" y Postgres deshace automáticamente cualquier transacción
-- que se haya quedado sin COMMIT explícito — por eso la primera vez no se borró
-- nada pese a no dar ningún error).
-- =====================================================================

BEGIN;

CREATE TEMP TABLE _usuarios_a_borrar ON COMMIT DROP AS
SELECT u."IdSistemaUsuario", u."IdAuthSupabase"
FROM "TSistemaUsuarios" u
WHERE NOT EXISTS (
    SELECT 1 FROM "TSistemaUsuariosRoles" ur
    JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
    WHERE ur."IdSistemaUsuario" = u."IdSistemaUsuario" AND r."Codigo" = 'ADMIN'
);

DELETE FROM "TSistemaUsuariosRoles"
WHERE "IdSistemaUsuario" IN (SELECT "IdSistemaUsuario" FROM _usuarios_a_borrar);

DELETE FROM "TSistemaUsuarios"
WHERE "IdSistemaUsuario" IN (SELECT "IdSistemaUsuario" FROM _usuarios_a_borrar);

DELETE FROM auth.users
WHERE id IN (SELECT "IdAuthSupabase" FROM _usuarios_a_borrar);

COMMIT;

-- Comprobación final (debería devolver solo administradores):
SELECT "IdSistemaUsuario", "Email", "Nombre" FROM "TSistemaUsuarios";
