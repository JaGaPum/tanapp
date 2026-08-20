-- =====================================================================
-- 058 - Baja de cuenta en autoservicio (CLIENTE y USUARIO_ORDINARIO)
-- =====================================================================
-- Hasta ahora solo el ADMIN podía desactivar una cuenta (toggle "Activo" en
-- UsuarioDetailScreen). Esta migración añade el registro de auditoría de las bajas que un
-- CLIENTE o USUARIO_ORDINARIO se dan a sí mismos desde su cuenta (ver AccountScreen):
--   - Sirve de disparador para notificar al admin (Database Webhook -> Edge Function
--     "enviar-push-baja", mismo patrón que "enviar-push-solicitud-cliente" sobre
--     "TClienteSolicitudes").
--   - Sirve de histórico para el gráfico "Altas y bajas por mes" del dashboard de admin: hoy
--     "Activo" es un simple booleano sin fecha, así que sin esta tabla no habría forma de saber
--     CUÁNDO se dio de baja alguien.
-- El propio "Activo=false" lo pone la app directamente sobre "TSistemaUsuarios" (ya se puede,
-- la policy "update_propio_o_admin_TSistemaUsuarios" de 002 no restringe columnas); esta tabla
-- es solo el registro de que ocurrió.
--
-- Requiere que 002 ya esté aplicado.

CREATE TABLE "TSistemaBajas" (
    "IdSistemaBaja" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Rol" varchar(20) NOT NULL CHECK ("Rol" IN ('CLIENTE', 'USUARIO_ORDINARIO')),
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaBajas"
    ADD CONSTRAINT "FK_TSistemaBajas_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

-- Para el gráfico "por mes" del dashboard, desglosado por rol.
CREATE INDEX "IX_TSistemaBajas_Rol_FechaAlta" ON "TSistemaBajas" ("Rol", "FechaAlta");

ALTER TABLE "TSistemaBajas" ENABLE ROW LEVEL SECURITY;

-- Cualquiera puede registrar SU PROPIA baja (self-service); no hay UPDATE/DELETE, es histórico
-- de auditoría igual que "TSistemaSuplantacionesLog"/"TSistemaSesionesSedesLog".
CREATE POLICY "insert_propia_TSistemaBajas" ON "TSistemaBajas"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Solo ADMIN las lista (dashboard).
CREATE POLICY "select_admin_TSistemaBajas" ON "TSistemaBajas"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));
