-- =====================================================================
-- 022 - En vez de un único campo "Detalles" libre, la publicación pasa a tener campos propios
--        (fecha de fallecimiento, edad, fecha/hora del funeral, lugar, capilla ardiente) que el
--        escaneo intenta rellenar por separado con patrones de texto, más un campo de
--        observaciones libre para que el propio usuario añada lo que quiera. Todos opcionales.
-- =====================================================================
-- Requiere que 021 ya esté aplicado.

ALTER TABLE "TClientePublicaciones" RENAME COLUMN "Detalles" TO "Observaciones";
ALTER TABLE "TClientePublicaciones" ALTER COLUMN "Observaciones" DROP NOT NULL;

ALTER TABLE "TClientePublicaciones" ADD COLUMN "FechaFallecimiento" date NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "Edad" smallint NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "FechaHoraFuneral" varchar(200) NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "Lugar" varchar(200) NULL;
ALTER TABLE "TClientePublicaciones" ADD COLUMN "CapillaArdiente" varchar(200) NULL;
