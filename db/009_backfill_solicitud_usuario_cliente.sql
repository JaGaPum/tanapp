-- =====================================================================
-- 009 - Rellena IdSistemaUsuarioCliente en solicitudes ya APROBADAS de antes
--        de que existiera ese enlace, cruzando por email
-- =====================================================================
-- Requiere que 008 ya esté aplicado.

UPDATE "TClienteSolicitudes" s
SET "IdSistemaUsuarioCliente" = u."IdSistemaUsuario"
FROM "TSistemaUsuarios" u
WHERE s."Estado" = 'APROBADA'
  AND s."IdSistemaUsuarioCliente" IS NULL
  AND lower(u."Email") = lower(s."EmailContacto");
