-- =====================================================================
-- 055 - Publicaciones y avisos programados
-- =====================================================================
-- Publicar una esquela o enviar un aviso admite ahora una fecha/hora futura ("programar") en
-- vez de siempre inmediato. Diseño de "cola": lo programado se guarda en estas dos tablas
-- nuevas (no en "TClientePublicaciones"/"TClienteAvisos" todavía), y un job de pg_cron
-- (056) las revisa cada pocos minutos e inserta en la tabla real lo que ya toque -momento en
-- el que se disparan solos, sin más cambios, el trigger de avisos push y cualquier otra cosa
-- que ya reaccione a un INSERT en esas tablas-. Mientras algo esté aquí, no existe de cara al
-- resto de la app (nadie más lo ve): solo lo ve su propio dueño, para poder revisarlo o
-- cancelarlo antes de que salga.
-- Requiere que 054 ya esté aplicado, y las extensiones "pg_cron" y "pg_net" activadas
-- (Database -> Extensions).

CREATE TABLE "TClientePublicacionesProgramadas" (
    "IdClientePublicacionProgramada" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClienteSede" uuid NOT NULL,
    "NombreFallecido" varchar(150) NOT NULL,
    "FechaFallecimiento" date NULL,
    "Edad" smallint NULL,
    "FechaFuneral" date NULL,
    "HoraFuneral" time NULL,
    "Iglesia" varchar(200) NULL,
    "Lugar" varchar(200) NULL,
    "CapillaArdiente" varchar(200) NULL,
    "Sala" varchar(200) NULL,
    "Observaciones" text NULL,
    "FechaProgramada" timestamptz NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClientePublicacionesProgramadas"
    ADD CONSTRAINT "FK_TClientePublicacionesProgramadas_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClientePublicacionesProgramadas_IdClienteSede"
    ON "TClientePublicacionesProgramadas" ("IdClienteSede");
CREATE INDEX "IX_TClientePublicacionesProgramadas_FechaProgramada"
    ON "TClientePublicacionesProgramadas" ("FechaProgramada");

CREATE TABLE "TClienteAvisosProgramados" (
    "IdClienteAvisoProgramado" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClienteSede" uuid NOT NULL,
    "Titulo" varchar(150) NOT NULL,
    "Texto" text NOT NULL,
    "FechaProgramada" timestamptz NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteAvisosProgramados"
    ADD CONSTRAINT "FK_TClienteAvisosProgramados_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClienteAvisosProgramados_IdClienteSede"
    ON "TClienteAvisosProgramados" ("IdClienteSede");
CREATE INDEX "IX_TClienteAvisosProgramados_FechaProgramada"
    ON "TClienteAvisosProgramados" ("FechaProgramada");

-- ---------------------------------------------------------------------
-- RLS: mismo patrón que "mutacion_propia_o_admin_TClientePublicaciones" (017) — el dueño de la
-- sede (o ADMIN) ve/gestiona lo programado de esa sede; nadie más ve nada aquí (a diferencia de
-- las tablas reales, esto no tiene política de SELECT pública).
-- ---------------------------------------------------------------------
ALTER TABLE "TClientePublicacionesProgramadas" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TClienteAvisosProgramados" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "mutacion_propia_o_admin_TClientePublicacionesProgramadas"
    ON "TClientePublicacionesProgramadas"
    FOR ALL TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClientePublicacionesProgramadas"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClientePublicacionesProgramadas"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "mutacion_propia_o_admin_TClienteAvisosProgramados"
    ON "TClienteAvisosProgramados"
    FOR ALL TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClienteAvisosProgramados"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClienteAvisosProgramados"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );
