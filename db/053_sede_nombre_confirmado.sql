-- =====================================================================
-- 053 - Confirmación explícita del nombre de cada sede
-- =====================================================================
-- La primera sede de un cliente recién aprobado se creaba con el nombre genérico "Sede
-- principal" (Edge Function "aprobar-solicitud-cliente"), y "tieneSedeSinRenombrarProvider"
-- comparaba contra ese texto fijo para bloquear publicar/enviar avisos hasta que se cambiase.
-- Ahora esa primera sede se crea con el propio nombre del cliente (más útil como punto de
-- partida que un genérico), así que ya no hay un texto fijo con el que comparar: se necesita un
-- flag explícito que diga si el cliente ha pasado por el formulario de la sede a confirmarlo (o
-- cambiarlo), diera igual el nombre con el que se creó.
--
-- Por defecto a "true": una sede dada de alta a mano desde "Mis sedes" ya lleva el nombre que
-- su dueño quiso ponerle, no hace falta confirmarla aparte. Solo la Edge Function pone "false"
-- explícitamente al crear la primera sede automática.

ALTER TABLE "TClienteSedes"
    ADD COLUMN "NombreConfirmado" boolean NOT NULL DEFAULT true;

-- Las sedes creadas automáticamente hasta ahora con el nombre genérico "Sede principal" (antes
-- de este cambio) tampoco han sido confirmadas por su dueño: se marcan igual para que a quien
-- le tocase el aviso siga viéndolo hasta que la revise, en vez de quedar "aprobada" sin más por
-- casualidad al aplicar esta migración.
UPDATE "TClienteSedes" SET "NombreConfirmado" = false WHERE "Nombre" = 'Sede principal';
