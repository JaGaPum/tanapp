-- =====================================================================
-- 043 - Registro de uso del escaneo de esquelas con IA (para el Dashboard del administrador)
-- =====================================================================
-- Una fila por cada llamada real a Claude desde "escanear-esquela-imagen" (no se cuentan los
-- intentos bloqueados por un interruptor desactivado: esos nunca llegan a la IA y no cuestan
-- nada). Guarda los tokens que devuelve la propia respuesta de Claude para poder estimar el
-- coste en la app (multiplicando por el precio público del modelo), sin depender de ninguna
-- API externa de facturación.
-- Requiere que 042 ya esté aplicado.

CREATE TABLE "TSistemaUsuarioEscaneoIaLog" (
    "IdSistemaUsuarioEscaneoIaLog" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Exito" boolean NOT NULL,
    "TokensEntrada" integer NULL,
    "TokensSalida" integer NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaUsuarioEscaneoIaLog"
    ADD CONSTRAINT "FK_TSistemaUsuarioEscaneoIaLog_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaUsuarioEscaneoIaLog_IdSistemaUsuario" ON "TSistemaUsuarioEscaneoIaLog" ("IdSistemaUsuario");
CREATE INDEX "IX_TSistemaUsuarioEscaneoIaLog_FechaAlta" ON "TSistemaUsuarioEscaneoIaLog" ("FechaAlta");

ALTER TABLE "TSistemaUsuarioEscaneoIaLog" ENABLE ROW LEVEL SECURITY;

-- Solo el administrador la consulta (Dashboard); la inserta la Edge Function con la
-- service_role, que salta la RLS, así que no hace falta policy de INSERT.
CREATE POLICY "select_admin_TSistemaUsuarioEscaneoIaLog" ON "TSistemaUsuarioEscaneoIaLog"
    FOR SELECT TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'));
