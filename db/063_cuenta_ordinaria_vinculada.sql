-- =====================================================================
-- 063 - Cuenta de usuario ordinario vinculada a un CLIENTE
-- =====================================================================
-- 052 quitó el rol USUARIO_ORDINARIO de las cuentas CLIENTE (mezclaba la navegación de negocio
-- con la de seguidor en una sola sesión). Para poder seguir clientes/zonas y dejar condolencias
-- como cualquier otra persona SIN mezclar esa navegación con la suya de negocio, un CLIENTE
-- puede tener una cuenta USUARIO_ORDINARIO propia y separada (login distinto, fila propia en
-- "TSistemaUsuarios"), y cambiar a ella y volver con el mismo mecanismo de intercambio de sesión
-- que ya usa la suplantación de admin (ver 046, y el arreglo de "elegir sede" durante
-- suplantación en la app).
--
-- La cuenta vinculada se crea sola (Edge Function "crear-cuenta-ordinaria-vinculada") la primera
-- vez que el cliente pulsa "Entrar en tu cuenta personal" desde Ajustes; a partir de ahí queda
-- enlazada aquí y se reutiliza siempre la misma.
--
-- Requiere que 002 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "IdSistemaUsuarioOrdinarioVinculado" uuid NULL;

ALTER TABLE "TSistemaUsuarios"
    ADD CONSTRAINT "FK_TSistemaUsuarios_IdSistemaUsuarioOrdinarioVinculado"
        FOREIGN KEY ("IdSistemaUsuarioOrdinarioVinculado")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE SET NULL;

-- Una cuenta ordinaria vinculada no puede pertenecer a más de un cliente a la vez.
CREATE UNIQUE INDEX "UX_TSistemaUsuarios_IdSistemaUsuarioOrdinarioVinculado"
    ON "TSistemaUsuarios" ("IdSistemaUsuarioOrdinarioVinculado")
    WHERE "IdSistemaUsuarioOrdinarioVinculado" IS NOT NULL;
