-- =====================================================================
-- 041 - Interruptor global para el escaneo de esquelas por foto con IA
-- =====================================================================
-- El escaneo actual hace OCR en el propio móvil y luego intenta adivinar cada campo con un
-- motor de reglas/regex hecho a mano: falla con cualquier plantilla de esquela que no encaje
-- con esas reglas. Esta columna activa (o desactiva) que, en su lugar, la foto se mande a la
-- Edge Function "escanear-esquela-imagen" (Claude con visión). Independiente de
-- "ImportacionWebIaActiva" (030): se puede activar el escaneo por foto sin activar el rastreo
-- de webs, o al revés. Cuando está a false, la pantalla de escanear sigue usando el OCR local
-- de siempre (nunca deja de funcionar del todo).
-- Requiere que 030 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD COLUMN "EscaneoEsquelaIaActiva" boolean NOT NULL DEFAULT false;
