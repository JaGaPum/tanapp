-- =====================================================================
-- 033 - El cliente puede eliminar avisos de su propio histórico de enviados
-- =====================================================================
-- "TClienteAvisos" es la fila de contenido compartida entre el remitente y todos sus
-- destinatarios: si el cliente pudiera borrarla de verdad, el ON DELETE CASCADE de
-- "TClienteAvisosDestinatarios" (031) haría desaparecer también el aviso del buzón de TODOS
-- los seguidores que ya lo recibieron, justo lo contrario de "cada uno elimina los suyos". En
-- vez de borrar la fila, se marca oculta solo para el propio cliente remitente; el seguidor
-- sigue viéndola en su buzón exactamente igual, sin enterarse.
-- Requiere que 032 ya esté aplicado.

ALTER TABLE "TClienteAvisos" ADD COLUMN "EliminadoCliente" boolean NOT NULL DEFAULT false;

-- No hace falta ninguna policy nueva: la policy de UPDATE del propio cliente dueño de la sede
-- (o ADMIN) ya existe desde 031 ("mutacion_propia_o_admin_TClienteAvisos") y cubre marcar esta
-- columna igual que cualquier otro campo.
