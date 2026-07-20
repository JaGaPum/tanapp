-- =====================================================================
-- 024 - Avisos de nuevas publicaciones + notificaciones push: cuando un cliente publica una
--        esquela, se crea un aviso (leído/no leído) para cada usuario que sigue esa sede, y
--        si el usuario tiene las notificaciones push activadas se le intenta avisar también
--        en el móvil (lo hace una Edge Function disparada por un Database Webhook, fuera de
--        esta migración). El aviso en la tabla se crea siempre, aunque el push falle o el
--        usuario no tenga el interruptor activado, para que la pestaña "Avisos" nunca dependa
--        de si el push llegó o no.
-- =====================================================================
-- Requiere que 023 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "NotificacionesPushActivas" boolean NOT NULL DEFAULT true;

-- Un token de FCM por dispositivo/instalación. Un mismo token solo puede pertenecer a un
-- usuario a la vez (si el mismo dispositivo cambia de cuenta, el registro se reasigna).
CREATE TABLE "TSistemaDispositivosPush" (
    "IdSistemaDispositivoPush" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Token" varchar(255) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaDispositivosPush"
    ADD CONSTRAINT "FK_TSistemaDispositivosPush_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE UNIQUE INDEX "UX_TSistemaDispositivosPush_Token" ON "TSistemaDispositivosPush" ("Token");
CREATE INDEX "IX_TSistemaDispositivosPush_IdSistemaUsuario" ON "TSistemaDispositivosPush" ("IdSistemaUsuario");

ALTER TABLE "TSistemaDispositivosPush" ENABLE ROW LEVEL SECURITY;

-- Cada usuario ve/gestiona solo sus propios tokens (mismo patrón que
-- TClientePublicacionesArchivadas en 021).
CREATE POLICY "select_propio_TSistemaDispositivosPush" ON "TSistemaDispositivosPush"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TSistemaDispositivosPush" ON "TSistemaDispositivosPush"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "delete_propio_TSistemaDispositivosPush" ON "TSistemaDispositivosPush"
    FOR DELETE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Un aviso por usuario destinatario y publicación (lo crea solo el trigger de más abajo, que
-- salta RLS por ser SECURITY DEFINER; no hay policy de INSERT para clientes).
CREATE TABLE "TSistemaAvisos" (
    "IdSistemaAviso" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "IdClientePublicacion" uuid NOT NULL,
    "Leido" boolean NOT NULL DEFAULT false,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaAvisos"
    ADD CONSTRAINT "FK_TSistemaAvisos_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TSistemaAvisos_IdClientePublicacion"
        FOREIGN KEY ("IdClientePublicacion")
        REFERENCES "TClientePublicaciones" ("IdClientePublicacion")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaAvisos_IdSistemaUsuario" ON "TSistemaAvisos" ("IdSistemaUsuario");
CREATE INDEX "IX_TSistemaAvisos_IdClientePublicacion" ON "TSistemaAvisos" ("IdClientePublicacion");

ALTER TABLE "TSistemaAvisos" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_propio_TSistemaAvisos" ON "TSistemaAvisos"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TSistemaAvisos" ON "TSistemaAvisos"
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

CREATE POLICY "delete_propio_TSistemaAvisos" ON "TSistemaAvisos"
    FOR DELETE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Al crearse una publicación, un aviso por cada usuario que siga esa sede. SQL puro (sin
-- llamadas de red) para que se ejecute en la misma transacción y nunca se pierda, aunque el
-- envío del push (Edge Function, disparada aparte por un Database Webhook) falle después.
CREATE OR REPLACE FUNCTION "FSistemaCrearAvisosPublicacion"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO "TSistemaAvisos" ("IdSistemaUsuario", "IdClientePublicacion")
    SELECT "IdSistemaUsuario", NEW."IdClientePublicacion"
    FROM "TClienteSeguimientos"
    WHERE "IdClienteSede" = NEW."IdClienteSede";
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_FSistemaCrearAvisosPublicacion"
    AFTER INSERT ON "TClientePublicaciones"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaCrearAvisosPublicacion"();
