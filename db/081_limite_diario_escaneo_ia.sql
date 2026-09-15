-- =====================================================================
-- 081 - Límite diario de escaneos con IA por cliente
-- =====================================================================
-- Protege frente a que un único cliente dispare el gasto escaneando la misma esquela muchas
-- veces: el ADMIN puede fijar un máximo de escaneos con IA al día por cliente (Configuración >
-- IA). NULL = sin límite (valor por defecto, no cambia el comportamiento actual hasta que el
-- ADMIN active uno). Al llegar al máximo, "escanear-esquela-imagen" rechaza la llamada con un
-- código reconocible para que la app pueda avisar en el formulario ("no se ha usado IA, revisa
-- con atención") en vez de caer al OCR local en silencio.
--
-- El día se cuenta en hora de Galicia (Europe/Madrid), no UTC, igual que ya se hace en 070 para
-- comparar "FechaFuneral"/"HoraFuneral" contra el momento actual.
--
-- Requiere que 043 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD COLUMN "MaxEscaneosIaPorDia" integer NULL
        CHECK ("MaxEscaneosIaPorDia" IS NULL OR "MaxEscaneosIaPorDia" > 0);

-- Cuántos escaneos con IA ha completado con éxito este cliente hoy (hora de Galicia). Solo
-- cuenta los que sí llegaron a llamar a Claude ("Exito" true/false ya distingue eso, ver 043);
-- los rechazados por este mismo límite nunca se registran en el log.
CREATE OR REPLACE FUNCTION "FSistemaContarEscaneosIaHoy"(p_id_sistema_usuario uuid)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT count(*)::integer
    FROM "TSistemaUsuarioEscaneoIaLog"
    WHERE "IdSistemaUsuario" = p_id_sistema_usuario
      AND "Exito" = true
      AND ("FechaAlta" AT TIME ZONE 'Europe/Madrid')::date
          = (now() AT TIME ZONE 'Europe/Madrid')::date;
$$;
