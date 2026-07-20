-- =====================================================================
-- 014 - Renombra el tipo de cliente "Eclesiástico" a "Parroquia"
-- =====================================================================
-- Requiere que 013 ya esté aplicado.

UPDATE "TConfiguracionClienteTipos" SET "Nombre" = 'Parroquia' WHERE "Nombre" = 'Eclesiástico';
UPDATE "TConfiguracionClienteTiposIdiomas" SET "Nombre" = 'Parroquia' WHERE "Nombre" = 'Eclesiástico';
