-- =====================================================================
-- 028 - Propuestas de publicación generadas por el rastreo automático de la web del cliente
-- =====================================================================
-- Segunda pieza de la importación automática (después de 027, que guarda la autorización y la
-- URL): aquí caen las esquelas que detecta el rastreo, en estado PENDIENTE, para que el cliente
-- las revise y publique él mismo desde el formulario manual — nunca se publican solas. Quien
-- las inserta es la Edge Function "escanear-webs-clientes" (service_role, sin policy de INSERT
-- para el cliente).
-- Requiere que 027 ya esté aplicado.

CREATE TABLE "TClientePublicacionesPropuestas" (
    "IdClientePublicacionPropuesta" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "NombreFallecido" varchar(200) NOT NULL,
    "FechaFallecimiento" date NULL,
    "Edad" integer NULL,
    "FechaFuneral" date NULL,
    "HoraFuneral" time NULL,
    "Iglesia" varchar(200) NULL,
    "Lugar" varchar(200) NULL,
    "CapillaArdiente" varchar(200) NULL,
    "Sala" varchar(100) NULL,
    "Observaciones" text NULL,
    "UrlOrigen" varchar(500) NOT NULL,
    "Fingerprint" varchar(64) NOT NULL,
    "Estado" varchar(20) NOT NULL DEFAULT 'PENDIENTE'
        CHECK ("Estado" IN ('PENDIENTE', 'DESCARTADA', 'PUBLICADA')),
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClientePublicacionesPropuestas"
    ADD CONSTRAINT "FK_TClientePublicacionesPropuestas_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

-- Un mismo rastreo repetido no duplica propuestas ya vistas (aunque el cliente la haya
-- descartado, no vuelve a aparecer).
CREATE UNIQUE INDEX "UX_TClientePublicacionesPropuestas_Usuario_Fingerprint"
    ON "TClientePublicacionesPropuestas" ("IdSistemaUsuario", "Fingerprint");
CREATE INDEX "IX_TClientePublicacionesPropuestas_IdSistemaUsuario_Estado"
    ON "TClientePublicacionesPropuestas" ("IdSistemaUsuario", "Estado");

ALTER TABLE "TClientePublicacionesPropuestas" ENABLE ROW LEVEL SECURITY;

-- El cliente ve y actualiza (descartar/marcar publicada) solo sus propias propuestas (mismo
-- patrón "propio" que TSistemaDispositivosPush en 024). Sin policy de INSERT: solo la Edge
-- Function, con service_role, inserta filas.
CREATE POLICY "select_propio_TClientePublicacionesPropuestas" ON "TClientePublicacionesPropuestas"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TClientePublicacionesPropuestas" ON "TClientePublicacionesPropuestas"
    FOR UPDATE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- =====================================================================
-- Disparo diario del rastreo (pg_cron + pg_net)
-- =====================================================================
-- Requiere habilitar antes las extensiones "pg_cron" y "pg_net" (Database -> Extensions).
-- Sustituye <URL_DEL_PROYECTO> (la URL base de tu proyecto Supabase, ej.
-- https://xxxxx.supabase.co), <CRON_SHARED_SECRET> (una cadena que te inventes, la misma que
-- pongas como secreto "CRON_SHARED_SECRET" de la Edge Function) y <SERVICE_ROLE_KEY> (Settings
-- -> API -> "service_role" — la pasarela de Supabase exige una cabecera "Authorization" antes
-- de dejar pasar la petición a la propia función, aparte de nuestro "X-Cron-Secret" propio; al
-- venir de una llamada interna de Postgres, no de la app, usar aquí la clave service_role es
-- seguro) y ejecuta este bloque a mano una vez desplegada la función "escanear-webs-clientes":
--
-- SELECT cron.schedule(
--   'escanear-webs-clientes-diario',
--   '0 6 * * *',
--   $$
--   SELECT net.http_post(
--     url := '<URL_DEL_PROYECTO>/functions/v1/escanear-webs-clientes',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'Authorization', 'Bearer <SERVICE_ROLE_KEY>',
--       'X-Cron-Secret', '<CRON_SHARED_SECRET>'
--     ),
--     body := '{}'::jsonb
--   );
--   $$
-- );
