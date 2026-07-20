-- =====================================================================
-- 012 - Seguidos: un usuario ordinario busca clientes (funeraria/tanatorio/
--        parroquia) activos y los sigue
-- =====================================================================
-- Requiere que 011 ya esté aplicado.

-- =====================================================================
-- 1. TSistemaUsuarios: cualquier autenticado puede ver clientes activos
--    (hoy solo se ve a sí mismo o, si es ADMIN, a todos). Policy adicional
--    y permisiva: se suma a "select_propio_o_admin_TSistemaUsuarios", no la
--    sustituye.
-- =====================================================================
CREATE POLICY "select_clientes_activos_TSistemaUsuarios" ON "TSistemaUsuarios"
    FOR SELECT TO authenticated
    USING (
        "Activo" = true
        AND EXISTS (
            SELECT 1
            FROM "TSistemaUsuariosRoles" ur
            JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
            WHERE ur."IdSistemaUsuario" = "TSistemaUsuarios"."IdSistemaUsuario"
              AND r."Codigo" = 'CLIENTE'
        )
    );

-- =====================================================================
-- 2. Tabla nueva: TClienteSeguimientos (quién sigue a qué cliente)
-- =====================================================================
CREATE TABLE "TClienteSeguimientos" (
    "IdClienteSeguimiento" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "IdSistemaUsuarioCliente" uuid NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteSeguimientos"
    ADD CONSTRAINT "FK_TClienteSeguimientos_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TClienteSeguimientos_IdSistemaUsuarioCliente"
        FOREIGN KEY ("IdSistemaUsuarioCliente")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE UNIQUE INDEX "UX_TClienteSeguimientos_Usuario_Cliente"
    ON "TClienteSeguimientos" ("IdSistemaUsuario", "IdSistemaUsuarioCliente");
CREATE INDEX "IX_TClienteSeguimientos_IdSistemaUsuarioCliente"
    ON "TClienteSeguimientos" ("IdSistemaUsuarioCliente");

ALTER TABLE "TClienteSeguimientos" ENABLE ROW LEVEL SECURITY;

-- Cada usuario ve/gestiona sus propios seguimientos; ADMIN ve todos (mismo patrón que
-- TSistemaSesiones en 003_sesiones_avatares_y_datos_personales.sql)
CREATE POLICY "select_propio_o_admin_TClienteSeguimientos" ON "TClienteSeguimientos"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TClienteSeguimientos" ON "TClienteSeguimientos"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "delete_propio_o_admin_TClienteSeguimientos" ON "TClienteSeguimientos"
    FOR DELETE TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );
