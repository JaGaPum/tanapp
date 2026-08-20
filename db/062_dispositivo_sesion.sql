-- =====================================================================
-- 062 - Información del dispositivo usado en cada sesión
-- =====================================================================
-- Para que el admin pueda ver, ficha de usuario > Sesiones, qué dispositivo se usó en cada una
-- (si se pudo detectar). Texto libre y opcional en vez de columnas separadas por fabricante/
-- modelo/SO: se resuelve en el cliente (device_info_plus, con distinto detalle según
-- Android/iOS/navegador web) y aquí solo se guarda ya formateado.
--
-- Requiere que 003 ya esté aplicado.

ALTER TABLE "TSistemaSesiones"
    ADD COLUMN "Dispositivo" varchar(200) NULL;
