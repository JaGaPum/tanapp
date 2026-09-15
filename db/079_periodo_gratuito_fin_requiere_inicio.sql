-- =====================================================================
-- 079 - El periodo gratuito no puede tener fecha de fin sin fecha de inicio
-- =====================================================================
-- Regla de negocio explícita: si no hay ningún periodo gratuito definido (ni general ni propio),
-- el cliente debe pagar -eso ya lo resuelve "FSistemaClienteEnPeriodoGratuito" (077/078) al
-- tratar "Inicio IS NULL" como "no hay periodo"-. Lo que faltaba era impedir a nivel de base de
-- datos un estado a medias (fecha de fin puesta pero sin fecha de inicio), que hasta ahora la
-- función simplemente ignoraba en silencio en vez de rechazarlo. Con fecha de inicio y sin fecha
-- de fin sigue significando "indefinido", eso no cambia.
--
-- Requiere que 078 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD CONSTRAINT "CK_TConfiguracionGlobal_PeriodoGratuitoFinRequiereInicio"
        CHECK ("PeriodoGratuitoFin" IS NULL OR "PeriodoGratuitoInicio" IS NOT NULL);

ALTER TABLE "TSistemaUsuarios"
    ADD CONSTRAINT "CK_TSistemaUsuarios_PeriodoGratuitoFinRequiereInicio"
        CHECK ("PeriodoGratuitoFin" IS NULL OR "PeriodoGratuitoInicio" IS NOT NULL);
