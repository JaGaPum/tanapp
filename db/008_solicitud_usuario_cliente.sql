-- =====================================================================
-- 008 - Enlaza la solicitud de cliente con el usuario que se le crea al
--        aprobarla, para saber si ya tiene cuenta y no ofrecer crearla de nuevo
-- =====================================================================
-- Requiere que 007 ya esté aplicado.

ALTER TABLE "TClienteSolicitudes"
    ADD COLUMN "IdSistemaUsuarioCliente" uuid NULL;

ALTER TABLE "TClienteSolicitudes"
    ADD CONSTRAINT "FK_TClienteSolicitudes_IdSistemaUsuarioCliente"
        FOREIGN KEY ("IdSistemaUsuarioCliente")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE SET NULL;
