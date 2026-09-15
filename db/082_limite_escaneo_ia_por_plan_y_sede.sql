-- =====================================================================
-- 082 - El límite de escaneos con IA pasa a depender del plan y se cuenta por sede
-- =====================================================================
-- Sustituye el límite global de 081 (una cifra para toda la app) por uno propio de cada plan de
-- suscripción (075): cada plan fija su propio máximo de escaneos con IA al día, igual que ya
-- fija su máximo de sedes. Y el conteo pasa a hacerse por sede (TClienteSedes), no por cliente:
-- un cliente con el plan Multisede y 3 sedes puede escanear hasta el máximo del plan EN CADA una
-- de sus sedes, no un total compartido entre las tres.
--
-- Requiere que 081 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    DROP COLUMN "MaxEscaneosIaPorDia";

ALTER TABLE "TConfiguracionPlanesSuscripcion"
    ADD COLUMN "MaxEscaneosIaPorDia" integer NULL
        CHECK ("MaxEscaneosIaPorDia" IS NULL OR "MaxEscaneosIaPorDia" > 0);

-- El log (043) pasa a guardar también la sede del escaneo, para poder contar por sede en vez de
-- por cliente. Nullable porque el histórico previo a esta migración no la tiene -esas filas
-- antiguas simplemente no cuentan para ninguna sede-.
ALTER TABLE "TSistemaUsuarioEscaneoIaLog"
    ADD COLUMN "IdClienteSede" uuid NULL;

ALTER TABLE "TSistemaUsuarioEscaneoIaLog"
    ADD CONSTRAINT "FK_TSistemaUsuarioEscaneoIaLog_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaUsuarioEscaneoIaLog_IdClienteSede" ON "TSistemaUsuarioEscaneoIaLog" ("IdClienteSede");

-- Cuántos escaneos con IA ha completado con éxito ESTA SEDE hoy (hora de Galicia).
CREATE OR REPLACE FUNCTION "FSistemaContarEscaneosIaHoy"(p_id_cliente_sede uuid)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT count(*)::integer
    FROM "TSistemaUsuarioEscaneoIaLog"
    WHERE "IdClienteSede" = p_id_cliente_sede
      AND "Exito" = true
      AND ("FechaAlta" AT TIME ZONE 'Europe/Madrid')::date
          = (now() AT TIME ZONE 'Europe/Madrid')::date;
$$;
