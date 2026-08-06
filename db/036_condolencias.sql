-- =====================================================================
-- 036 - Libro de condolencias: un mensaje de pésame por usuario y esquela
-- =====================================================================
-- Cualquier usuario autenticado puede dejar un mensaje de condolencia en una publicación
-- visible (una por usuario y esquela, la puede editar o borrar después). Se ven públicamente
-- junto con la esquela, igual que en cualquier libro de condolencias real. Solo el propio
-- autor puede editar/borrar la suya; ADMIN puede borrar cualquiera por moderación.
-- Requiere que 035 ya esté aplicado.

CREATE TABLE "TClientePublicacionesCondolencias" (
    "IdClientePublicacionCondolencia" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClientePublicacion" uuid NOT NULL,
    "IdSistemaUsuario" uuid NOT NULL,
    "Texto" text NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClientePublicacionesCondolencias"
    ADD CONSTRAINT "FK_TClientePublicacionesCondolencias_IdClientePublicacion"
        FOREIGN KEY ("IdClientePublicacion")
        REFERENCES "TClientePublicaciones" ("IdClientePublicacion")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TClientePublicacionesCondolencias_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

-- Una condolencia por usuario y esquela: se edita la propia en vez de acumular varias.
CREATE UNIQUE INDEX "UX_TClientePublicacionesCondolencias_Publicacion_Usuario"
    ON "TClientePublicacionesCondolencias" ("IdClientePublicacion", "IdSistemaUsuario");
CREATE INDEX "IX_TClientePublicacionesCondolencias_IdClientePublicacion"
    ON "TClientePublicacionesCondolencias" ("IdClientePublicacion");

ALTER TABLE "TClientePublicacionesCondolencias" ENABLE ROW LEVEL SECURITY;

-- Mismo patrón que "select_clientes_activos_TClientePublicaciones" (017): visible a cualquier
-- autenticado si la publicación es de un cliente activo.
CREATE POLICY "select_clientes_activos_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClientePublicaciones" p
            JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
            WHERE p."IdClientePublicacion" = "TClientePublicacionesCondolencias"."IdClientePublicacion"
              AND "FSistemaUsuarioEsClienteActivo"(s."IdSistemaUsuario")
        )
    );

CREATE POLICY "insert_propio_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
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

CREATE POLICY "delete_propio_o_admin_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
    FOR DELETE TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE TRIGGER "trigger_FechaModificacion_TClientePublicacionesCondolencias"
    BEFORE UPDATE ON "TClientePublicacionesCondolencias"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();
