-- =====================================================================
-- 071 - Recordatorios ya enviados: distinguir leído/no leído, igual que los avisos
-- =====================================================================
-- Cuando un recordatorio (070) se marca "Enviado" y pasa a verse en la pestaña "Avisos" >
-- "Recibidos", hace falta poder distinguir cuáles ya se han abierto de cuáles no -mismo criterio
-- que "TClienteAvisosDestinatarios.Leido" (031)-. La política de UPDATE "propio" ya existente
-- (070) vale tal cual: el propio destinatario ya puede marcar sus filas como leídas.
--
-- Requiere que 070 ya esté aplicado.

ALTER TABLE "TClientePublicacionesRecordatorios"
    ADD COLUMN "Leido" boolean NOT NULL DEFAULT false;
