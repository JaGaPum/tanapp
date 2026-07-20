-- =====================================================================
-- 015 - Sedes de cliente: un cliente puede tener varias ubicaciones (nombre,
--        provincia, concello, dirección propios de cada una). Buscar/Seguindo/
--        "Cómo llegar" pasan a operar sobre la sede, no sobre el cliente.
-- =====================================================================
-- Requiere que 014 ya esté aplicado.

-- =====================================================================
-- 1. Tabla nueva: TClienteSedes
-- =====================================================================
CREATE TABLE "TClienteSedes" (
    "IdClienteSede" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Nombre" varchar(150) NOT NULL,
    "Provincia" varchar(150) NOT NULL,
    "Concello" varchar(150) NOT NULL,
    "Direccion" varchar(255) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TClienteSedes"
    ADD CONSTRAINT "FK_TClienteSedes_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TClienteSedes_IdSistemaUsuario" ON "TClienteSedes" ("IdSistemaUsuario");

ALTER TABLE "TClienteSedes" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TClienteSedes"
    BEFORE UPDATE ON "TClienteSedes"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Cualquier autenticado ve las sedes de un cliente activo (para Buscar/Seguindo); el propio
-- cliente o ADMIN puede además insertar/editar/borrar las suyas.
CREATE POLICY "select_clientes_activos_TClienteSedes" ON "TClienteSedes"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioEsClienteActivo"("IdSistemaUsuario"));

CREATE POLICY "mutacion_propia_o_admin_TClienteSedes" ON "TClienteSedes"
    FOR ALL TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- =====================================================================
-- 2. Backfill: crea una "Sede principal" para cada cliente ya aprobado que
--    tenga dirección propia (perfil genérico de TSistemaUsuarios) y aún no
--    tenga ninguna sede, para no dejarlo sin ninguna.
-- =====================================================================
INSERT INTO "TClienteSedes" ("IdSistemaUsuario", "Nombre", "Provincia", "Concello", "Direccion")
SELECT u."IdSistemaUsuario", 'Sede principal', u."Provincia", u."Concello", u."Direccion"
FROM "TSistemaUsuarios" u
WHERE EXISTS (
        SELECT 1
        FROM "TSistemaUsuariosRoles" ur
        JOIN "TSistemaRoles" r ON r."IdSistemaRol" = ur."IdSistemaRol"
        WHERE ur."IdSistemaUsuario" = u."IdSistemaUsuario" AND r."Codigo" = 'CLIENTE'
      )
  AND u."Provincia" IS NOT NULL
  AND u."Concello" IS NOT NULL
  AND u."Direccion" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "TClienteSedes" s WHERE s."IdSistemaUsuario" = u."IdSistemaUsuario");

-- =====================================================================
-- 3. TClienteSeguimientos: pasa a apuntar a una sede en vez de al cliente
-- =====================================================================
ALTER TABLE "TClienteSeguimientos" ADD COLUMN "IdClienteSede" uuid NULL;

UPDATE "TClienteSeguimientos" f
SET "IdClienteSede" = s."IdClienteSede"
FROM "TClienteSedes" s
WHERE s."IdSistemaUsuario" = f."IdSistemaUsuarioCliente"
  AND f."IdClienteSede" IS NULL;

-- Seguimientos que no se han podido reasignar (el cliente no tenía dirección previa, caso
-- de datos de prueba): se eliminan, no se pueden reconstruir.
DELETE FROM "TClienteSeguimientos" WHERE "IdClienteSede" IS NULL;

ALTER TABLE "TClienteSeguimientos" DROP CONSTRAINT "FK_TClienteSeguimientos_IdSistemaUsuarioCliente";
DROP INDEX "UX_TClienteSeguimientos_Usuario_Cliente";
DROP INDEX "IX_TClienteSeguimientos_IdSistemaUsuarioCliente";
ALTER TABLE "TClienteSeguimientos" DROP COLUMN "IdSistemaUsuarioCliente";

ALTER TABLE "TClienteSeguimientos" ALTER COLUMN "IdClienteSede" SET NOT NULL;
ALTER TABLE "TClienteSeguimientos"
    ADD CONSTRAINT "FK_TClienteSeguimientos_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE UNIQUE INDEX "UX_TClienteSeguimientos_Usuario_Sede"
    ON "TClienteSeguimientos" ("IdSistemaUsuario", "IdClienteSede");
CREATE INDEX "IX_TClienteSeguimientos_IdClienteSede" ON "TClienteSeguimientos" ("IdClienteSede");
