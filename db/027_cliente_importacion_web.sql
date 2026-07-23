-- =====================================================================
-- 027 - Autorización del cliente para importar datos desde su web
-- =====================================================================
-- Primer paso de cara a que una IA rastree la web de cada cliente y proponga esquelas
-- automáticamente: por ahora solo se guarda la autorización del cliente y la URL de su web.
-- El rastreo/importación en sí queda para más adelante.
-- Requiere que 026 ya esté aplicado.

CREATE TABLE "TClienteImportacionWeb" (
    "IdClienteImportacionWeb" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Url" varchar(500) NOT NULL,
    "Activo" boolean NOT NULL DEFAULT true,
    "FechaAutorizacion" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteImportacionWeb"
    ADD CONSTRAINT "FK_TClienteImportacionWeb_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

-- Una fila por cliente: se actualiza (upsert), no se acumula histórico.
CREATE UNIQUE INDEX "UX_TClienteImportacionWeb_IdSistemaUsuario"
    ON "TClienteImportacionWeb" ("IdSistemaUsuario");

ALTER TABLE "TClienteImportacionWeb" ENABLE ROW LEVEL SECURITY;

-- Cada cliente ve/gestiona solo su propia configuración (mismo patrón que
-- TSistemaDispositivosPush en 024). Sin policy de DELETE: para desactivar se pone
-- "Activo" = false, no se borra la fila.
CREATE POLICY "select_propio_TClienteImportacionWeb" ON "TClienteImportacionWeb"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TClienteImportacionWeb" ON "TClienteImportacionWeb"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "update_propio_TClienteImportacionWeb" ON "TClienteImportacionWeb"
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

CREATE TRIGGER "trigger_FechaModificacion_TClienteImportacionWeb"
    BEFORE UPDATE ON "TClienteImportacionWeb"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();
