-- =====================================================================
-- 023 - Separa la iglesia y la sala del velatorio en sus propios campos: hasta ahora "Lugar"
--        mezclaba el nombre de la iglesia con la localidad, y "CapillaArdiente" a veces
--        arrastraba también el nombre de la sala. "Lugar" pasa a contener solo la localidad
--        (lo que va entre paréntesis tras la iglesia); "Iglesia" y "Sala" son campos nuevos.
-- =====================================================================
-- Requiere que 022 ya esté aplicado.

ALTER TABLE "TClientePublicaciones" ADD COLUMN "Iglesia" varchar(200) NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "Sala" varchar(200) NULL;
