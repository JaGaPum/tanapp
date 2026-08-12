-- =====================================================================
-- 048 - Sesiones concurrentes por sede (máx. 2 por sede) para clientes con varias sedes
-- =====================================================================
-- Hasta ahora, un login explícito (SesionPolicyService.registrarLoginExplicito) cerraba
-- cualquier otra sesión abierta del mismo usuario: solo se podía estar conectado en un sitio
-- a la vez. Un cliente con varias sedes/tanatorios necesita que su personal pueda trabajar a
-- la vez desde varios sitios con la misma cuenta, indicando en qué sede trabaja cada sesión.
-- Ese cierre automático se quita en el código (no aquí); esta migración añade lo necesario
-- para poder acotar cada sesión a una sede y limitar cuántas sesiones abiertas puede haber
-- a la vez trabajando "como" una misma sede.
--
-- Requiere que 047 ya esté aplicado.

-- 1. Sede que tiene asignada la sesión ahora mismo (null hasta que se elige, o si el usuario
--    no es CLIENTE / solo tiene una sede y se le asigna sola).
ALTER TABLE "TSistemaSesiones"
    ADD COLUMN "IdClienteSede" uuid NULL;

ALTER TABLE "TSistemaSesiones"
    ADD CONSTRAINT "FK_TSistemaSesiones_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE SET NULL;

-- Para el recuento "cuántas sesiones abiertas hay ya en esta sede" (límite de 2).
CREATE INDEX "IX_TSistemaSesiones_Sede_Abiertas"
    ON "TSistemaSesiones" ("IdSistemaUsuario", "IdClienteSede")
    WHERE "Estado" = 'ABIERTA';

-- 2. Historial de a qué sedes ha estado asignada una sesión a lo largo de su vida (una fila
--    por cada asignación/cambio, no solo la actual) — mismo patrón de tabla de auditoría que
--    "TSistemaSuplantacionesLog" (046): solo inserta la app, nunca se actualiza ni se borra.
CREATE TABLE "TSistemaSesionesSedesLog" (
    "IdSistemaSesionSedeLog" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaSesion" uuid NOT NULL,
    "IdClienteSede" uuid NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaSesionesSedesLog"
    ADD CONSTRAINT "FK_TSistemaSesionesSedesLog_IdSistemaSesion"
        FOREIGN KEY ("IdSistemaSesion")
        REFERENCES "TSistemaSesiones" ("IdSistemaSesion")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TSistemaSesionesSedesLog_IdClienteSede"
        FOREIGN KEY ("IdClienteSede")
        REFERENCES "TClienteSedes" ("IdClienteSede")
        ON DELETE CASCADE;

CREATE INDEX "IX_TSistemaSesionesSedesLog_IdSistemaSesion" ON "TSistemaSesionesSedesLog" ("IdSistemaSesion");

ALTER TABLE "TSistemaSesionesSedesLog" ENABLE ROW LEVEL SECURITY;

-- Mismo criterio "propio o admin" que TSistemaSesiones, vía la sesión a la que pertenece.
CREATE POLICY "select_propio_o_admin_TSistemaSesionesSedesLog" ON "TSistemaSesionesSedesLog"
    FOR SELECT TO authenticated
    USING (
        "FSistemaUsuarioTieneRol"('ADMIN')
        OR "IdSistemaSesion" IN (
            SELECT "IdSistemaSesion" FROM "TSistemaSesiones"
            WHERE "IdSistemaUsuario" IN (
                SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
            )
        )
    );

CREATE POLICY "insert_propio_TSistemaSesionesSedesLog" ON "TSistemaSesionesSedesLog"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaSesion" IN (
            SELECT "IdSistemaSesion" FROM "TSistemaSesiones"
            WHERE "IdSistemaUsuario" IN (
                SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
            )
        )
    );

-- 3. Listado para la pestaña "En vivo" del admin: sesiones abiertas con el nombre de usuario y
--    de sede ya resueltos (PostgREST no puede embeber "TSistemaUsuarios"/"TClienteSedes" con
--    columnas de nombre propio elegidas a mano, así que es más simple resolverlo en una función
--    que el admin invoca por RPC). SECURITY INVOKER (por defecto): corre como quien llama, así
--    que sigue haciendo falta ser ADMIN para ver las sesiones de los demás (RLS de
--    TSistemaSesiones ya lo exige); no se usa SECURITY DEFINER porque no hace falta saltarse RLS.
CREATE OR REPLACE FUNCTION "FSistemaSesionesAbiertas"()
RETURNS TABLE (
    "IdSistemaSesion" uuid,
    "IdSistemaUsuario" uuid,
    "NombreUsuario" varchar,
    "EmailUsuario" varchar,
    "IdClienteSede" uuid,
    "NombreSede" varchar,
    "FechaInicio" timestamptz,
    "FechaUltimoAcceso" timestamptz,
    "Recordar" boolean
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        s."IdSistemaSesion",
        s."IdSistemaUsuario",
        u."Nombre",
        u."Email",
        s."IdClienteSede",
        sede."Nombre",
        s."FechaInicio",
        s."FechaUltimoAcceso",
        s."Recordar"
    FROM "TSistemaSesiones" s
    JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
    LEFT JOIN "TClienteSedes" sede ON sede."IdClienteSede" = s."IdClienteSede"
    WHERE s."Estado" = 'ABIERTA'
    ORDER BY s."FechaUltimoAcceso" DESC;
$$;

GRANT EXECUTE ON FUNCTION "FSistemaSesionesAbiertas"() TO authenticated;
