-- =====================================================================
-- 031 - Avisos de texto libre de un cliente a sus seguidores (p.ej. cambio de horario)
-- =====================================================================
-- Distinto de "TSistemaAvisos" (024), que son avisos automáticos de "hay una publicación
-- nueva" generados por trigger. Aquí el propio cliente redacta un título y un texto y lo manda
-- a mano a quien siga esa sede. Mismo patrón que 017/024: la tabla de contenido
-- (TClienteAvisos) más una tabla de buzón por destinatario (TClienteAvisosDestinatarios, con su
-- "Leido") rellenada por un trigger SQL en la misma transacción, para que el buzón del seguidor
-- nunca dependa de que el push (Edge Function aparte, disparada por un Database Webhook sobre
-- INSERT en TClienteAvisosDestinatarios) llegue a enviarse.
-- Requiere que 030 ya esté aplicado.

CREATE TABLE "TClienteAvisos" (
    "IdClienteAviso" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClienteSede" uuid NOT NULL,
    "Titulo" varchar(150) NOT NULL,
    "Texto" text NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteAvisos"
    ADD CONSTRAINT "FK_TClienteAvisos_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClienteAvisos_IdClienteSede" ON "TClienteAvisos" ("IdClienteSede");

ALTER TABLE "TClienteAvisos" ENABLE ROW LEVEL SECURITY;

-- Mismo patrón que "select_clientes_activos_TClientePublicaciones"/"mutacion_propia_o_admin_..."
-- en 017: cualquier autenticado puede leer los avisos de una sede de un cliente activo (los
-- necesita el seguidor para ver el histórico igual que con las publicaciones); solo el propio
-- cliente dueño de la sede o ADMIN puede crearlos/editarlos/borrarlos.
CREATE POLICY "select_clientes_activos_TClienteAvisos" ON "TClienteAvisos"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            WHERE s."IdClienteSede" = "TClienteAvisos"."IdClienteSede"
              AND "FSistemaUsuarioEsClienteActivo"(s."IdSistemaUsuario")
        )
    );

CREATE POLICY "mutacion_propia_o_admin_TClienteAvisos" ON "TClienteAvisos"
    FOR ALL TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClienteAvisos"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClienteAvisos"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );

-- Buzón por destinatario (uno por seguidor de la sede en el momento del envío), mismo patrón
-- que "TSistemaAvisos" en 024: solo lo crea el trigger de más abajo (SECURITY DEFINER, salta
-- RLS); el destinatario solo puede leer y marcar como leído el suyo.
CREATE TABLE "TClienteAvisosDestinatarios" (
    "IdClienteAvisoDestinatario" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClienteAviso" uuid NOT NULL,
    "IdSistemaUsuario" uuid NOT NULL,
    "Leido" boolean NOT NULL DEFAULT false,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteAvisosDestinatarios"
    ADD CONSTRAINT "FK_TClienteAvisosDestinatarios_IdClienteAviso"
        FOREIGN KEY ("IdClienteAviso")
        REFERENCES "TClienteAvisos" ("IdClienteAviso")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TClienteAvisosDestinatarios_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE UNIQUE INDEX "UX_TClienteAvisosDestinatarios_Aviso_Usuario"
    ON "TClienteAvisosDestinatarios" ("IdClienteAviso", "IdSistemaUsuario");
CREATE INDEX "IX_TClienteAvisosDestinatarios_IdSistemaUsuario" ON "TClienteAvisosDestinatarios" ("IdSistemaUsuario");

ALTER TABLE "TClienteAvisosDestinatarios" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_propio_TClienteAvisosDestinatarios" ON "TClienteAvisosDestinatarios"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TClienteAvisosDestinatarios" ON "TClienteAvisosDestinatarios"
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

-- Al crearse un aviso, una fila de buzón por cada usuario que siga esa sede. SQL puro (sin
-- llamadas de red) para que se ejecute en la misma transacción y nunca se pierda, aunque el
-- envío del push falle después.
CREATE OR REPLACE FUNCTION "FSistemaCrearDestinatariosClienteAviso"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO "TClienteAvisosDestinatarios" ("IdClienteAviso", "IdSistemaUsuario")
    SELECT NEW."IdClienteAviso", "IdSistemaUsuario"
    FROM "TClienteSeguimientos"
    WHERE "IdClienteSede" = NEW."IdClienteSede";
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_FSistemaCrearDestinatariosClienteAviso"
    AFTER INSERT ON "TClienteAvisos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaCrearDestinatariosClienteAviso"();
