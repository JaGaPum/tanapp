-- =====================================================================
-- 046 - Registro de auditoría de suplantaciones (un administrador "inicia sesión como" otro
--        usuario, para depurar incidencias tal cual las ve él)
-- =====================================================================
-- Solo guarda el registro: quién suplantó a quién y cuándo. La suplantación en sí la hace la
-- Edge Function "suplantar-usuario" (con la clave de servicio, comprobando primero que quien
-- llama es ADMIN y que el objetivo no lo es); esta tabla es solo la traza de auditoría, no hay
-- policy de INSERT para clientes porque el registro lo escribe siempre esa función.
-- Requiere que las tablas TSistemaUsuarios/TSistemaUsuariosRoles/TSistemaRoles ya existan.

CREATE TABLE "TSistemaSuplantacionesLog" (
    "IdSistemaSuplantacionLog" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuarioAdmin" uuid NOT NULL,
    "IdSistemaUsuarioObjetivo" uuid NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaSuplantacionesLog"
    ADD CONSTRAINT "FK_TSistemaSuplantacionesLog_Admin"
        FOREIGN KEY ("IdSistemaUsuarioAdmin")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TSistemaSuplantacionesLog_Objetivo"
        FOREIGN KEY ("IdSistemaUsuarioObjetivo")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaSuplantacionesLog_Admin" ON "TSistemaSuplantacionesLog" ("IdSistemaUsuarioAdmin");
CREATE INDEX "IX_TSistemaSuplantacionesLog_Objetivo" ON "TSistemaSuplantacionesLog" ("IdSistemaUsuarioObjetivo");

ALTER TABLE "TSistemaSuplantacionesLog" ENABLE ROW LEVEL SECURITY;

-- Solo un ADMIN puede consultar el histórico (auditoría); nadie puede insertar/editar/borrar
-- desde la app, solo la Edge Function con service_role (que salta RLS).
CREATE POLICY "select_admin_TSistemaSuplantacionesLog" ON "TSistemaSuplantacionesLog"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));
