-- =====================================================================
-- 030 - Configuración global > interruptor de la importación de esquelas con IA
-- =====================================================================
-- Fila única (a diferencia del resto de tablas "TConfiguracion*", que son catálogos con muchas
-- filas) para parámetros globales de la app. Por ahora solo guarda si la importación automática
-- de esquelas con IA (rastreo web, ver 027/028/029) está activa a nivel de todo el sistema: se
-- desactiva temporalmente sin tener que tocar código ni desplegar nada, y cuando esté a false
-- ningún cliente puede activar su propia importación ni ver sus propuestas pendientes, y la
-- Edge Function "escanear-webs-clientes" no procesa a nadie aunque tengan su Url configurada.
-- Requiere que 029 ya esté aplicado.

CREATE TABLE "TConfiguracionGlobal" (
    "IdConfiguracionGlobal" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "ImportacionWebIaActiva" boolean NOT NULL DEFAULT true,
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

-- Se desactiva de entrada: todavía no se ha ofrecido la importación con IA a los clientes.
INSERT INTO "TConfiguracionGlobal" ("ImportacionWebIaActiva") VALUES (false);

ALTER TABLE "TConfiguracionGlobal" ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado necesita poder leerla, para saber si mostrar las opciones de
-- importación/propuestas. Sin policies de INSERT/DELETE: la fila única la crea esta migración y
-- no se puede borrar ni duplicar desde la app.
CREATE POLICY "select_authenticated_TConfiguracionGlobal" ON "TConfiguracionGlobal"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "update_admin_TConfiguracionGlobal" ON "TConfiguracionGlobal"
    FOR UPDATE TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionGlobal"
    BEFORE UPDATE ON "TConfiguracionGlobal"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();
