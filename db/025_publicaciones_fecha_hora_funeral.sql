-- =====================================================================
-- 025 - Separa "FechaHoraFuneral" (texto libre) en dos campos reales: "FechaFuneral" (date) y
--        "HoraFuneral" (time). El escaneo pasa a traducir el día de la semana y la hora en
--        letra leídos en la esquela a estos dos formatos, en vez de dejarlos como frase libre.
-- =====================================================================
-- Requiere que 024 ya esté aplicado.

ALTER TABLE "TClientePublicaciones" DROP COLUMN "FechaHoraFuneral";
ALTER TABLE "TClientePublicaciones" ADD COLUMN "FechaFuneral" date NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "HoraFuneral" time NULL;
