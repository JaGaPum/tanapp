-- =====================================================================
-- 017 - Publicaciones de clientes (esquelas): un cliente Funeraria/Tanatorio
--        publica el fallecimiento de una persona desde una de sus sedes.
--        Por protección de datos NO se guardan datos personales de
--        familiares: solo el nombre del fallecido y un texto libre con la
--        información relevante (horarios, lugar, etc.), redactado por el
--        propio cliente.
-- =====================================================================
-- Requiere que 016 ya esté aplicado.

CREATE TABLE "TClientePublicaciones" (
    "IdClientePublicacion" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdClienteSede" uuid NOT NULL,
    "NombreFallecido" varchar(150) NOT NULL,
    "Detalles" text NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClientePublicaciones"
    ADD CONSTRAINT "FK_TClientePublicaciones_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClientePublicaciones_IdClienteSede" ON "TClientePublicaciones" ("IdClienteSede");

ALTER TABLE "TClientePublicaciones" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TClientePublicaciones"
    BEFORE UPDATE ON "TClientePublicaciones"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Cualquier autenticado ve las publicaciones de una sede de un cliente activo (mismo patrón
-- que "select_clientes_activos_TClienteSedes" en 015); el propio cliente dueño de la sede o
-- ADMIN puede además insertar/editar/borrar.
CREATE POLICY "select_clientes_activos_TClientePublicaciones" ON "TClientePublicaciones"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            WHERE s."IdClienteSede" = "TClientePublicaciones"."IdClienteSede"
              AND "FSistemaUsuarioEsClienteActivo"(s."IdSistemaUsuario")
        )
    );

CREATE POLICY "mutacion_propia_o_admin_TClientePublicaciones" ON "TClientePublicaciones"
    FOR ALL TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClientePublicaciones"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR EXISTS (
            SELECT 1 FROM "TClienteSedes" s
            JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE s."IdClienteSede" = "TClientePublicaciones"."IdClienteSede"
              AND u."IdAuthSupabase" = auth.uid()
        )
    );
