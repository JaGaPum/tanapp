-- =====================================================================
-- 021 - Arquivo: un usuario ordinario puede guardar publicaciones que ve en el Taboleiro o en
--        Seguindo para volver a verlas después en su propia pestaña "Arquivo".
-- =====================================================================
-- Requiere que 020 ya esté aplicado.

CREATE TABLE "TClientePublicacionesArchivadas" (
    "IdClientePublicacionArchivada" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "IdClientePublicacion" uuid NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClientePublicacionesArchivadas"
    ADD CONSTRAINT "FK_TClientePublicacionesArchivadas_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TClientePublicacionesArchivadas_IdClientePublicacion"
        FOREIGN KEY ("IdClientePublicacion")
        REFERENCES "TClientePublicaciones" ("IdClientePublicacion")
        ON DELETE CASCADE;

CREATE UNIQUE INDEX "UX_TClientePublicacionesArchivadas_Usuario_Publicacion"
    ON "TClientePublicacionesArchivadas" ("IdSistemaUsuario", "IdClientePublicacion");
CREATE INDEX "IX_TClientePublicacionesArchivadas_IdClientePublicacion"
    ON "TClientePublicacionesArchivadas" ("IdClientePublicacion");

ALTER TABLE "TClientePublicacionesArchivadas" ENABLE ROW LEVEL SECURITY;

-- Cada usuario ve/gestiona solo lo que él mismo ha archivado (mismo patrón que
-- TClienteSeguimientos en 012: subconsulta directa a TSistemaUsuarios, no hay recursión
-- porque la policy vive en esta tabla, no en TSistemaUsuarios).
CREATE POLICY "select_propio_TClientePublicacionesArchivadas" ON "TClientePublicacionesArchivadas"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TClientePublicacionesArchivadas" ON "TClientePublicacionesArchivadas"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "delete_propio_TClientePublicacionesArchivadas" ON "TClientePublicacionesArchivadas"
    FOR DELETE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );
