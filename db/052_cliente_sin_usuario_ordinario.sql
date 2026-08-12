-- =====================================================================
-- 052 - Un CLIENTE no debe tener también USUARIO_ORDINARIO
-- =====================================================================
-- "FSistemaHandleNewAuthUser" (002 y sucesivas) asigna USUARIO_ORDINARIO a CUALQUIER alta en
-- auth.users, sin saber todavía si acabará siendo un cliente (funeraria/tanatorio/parroquia) o
-- un usuario particular. La Edge Function "aprobar-solicitud-cliente" añadía el rol CLIENTE
-- encima sin quitar ese USUARIO_ORDINARIO, así que toda cuenta de cliente aprobada hasta ahora
-- tiene los dos roles a la vez -no debería, es una cuenta de negocio, no un seguidor particular-.
-- Esta migración limpia los datos ya existentes; la Edge Function (deploy aparte, no hay nada
-- que desplegar por SQL) ya deja de asignarlo para las altas nuevas.

DELETE FROM "TSistemaUsuariosRoles"
WHERE "IdSistemaRol" = (
    SELECT "IdSistemaRol" FROM "TSistemaRoles" WHERE "Codigo" = 'USUARIO_ORDINARIO'
)
AND "IdSistemaUsuario" IN (
    SELECT ur."IdSistemaUsuario"
    FROM "TSistemaUsuariosRoles" ur
    JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
    WHERE r."Codigo" = 'CLIENTE'
);
