-- =====================================================================
-- 042 - Desactivar el escaneo de esquelas con IA para un usuario concreto
-- =====================================================================
-- Además del interruptor global (041), el administrador necesita poder cortarle el acceso a
-- un cliente en particular (p. ej. si abusa del escaneo) sin tener que desactivarlo para todos.
-- Por defecto a true: activar la 041 no debe dejar sin escaneo con IA a nadie que ya lo tuviera
-- disponible; es el admin quien desactiva casos concretos desde la ficha de usuario.
-- Requiere que 041 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "EscaneoEsquelaIaActiva" boolean NOT NULL DEFAULT true;
