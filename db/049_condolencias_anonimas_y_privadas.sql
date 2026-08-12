-- =====================================================================
-- 049 - Condolencias anónimas y privadas
-- =====================================================================
-- Al escribir (o editar) una condolencia, el autor puede marcarla como:
--   - Anónima: su nombre no se muestra a nadie, ni a otros usuarios ni al cliente dueño de la
--     esquela (solo el propio autor y ADMIN siguen viendo quién la escribió).
--   - Privada: solo la ve el cliente dueño de la esquela (aparte del propio autor y ADMIN); el
--     resto de usuarios ni siquiera sabe que existe.
-- El recuento de condolencias (Taboleiro, búsqueda histórica, PDF) sigue contando TODAS,
-- anónimas y privadas incluidas: solo cambia quién puede ver el contenido y el nombre.
-- Requiere que 048 ya esté aplicado.

ALTER TABLE "TClientePublicacionesCondolencias"
    ADD COLUMN "Anonima" boolean NOT NULL DEFAULT false,
    ADD COLUMN "Privada" boolean NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------
-- 1. RLS de la tabla base: además de "cliente activo" (visibilidad de siempre), una condolencia
--    privada solo la ve su propio autor, el cliente dueño de la esquela, o ADMIN.
-- ---------------------------------------------------------------------
DROP POLICY "select_clientes_activos_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias";

CREATE POLICY "select_visibles_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClientePublicaciones" p
            JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
            WHERE p."IdClientePublicacion" = "TClientePublicacionesCondolencias"."IdClientePublicacion"
              AND "FSistemaUsuarioEsClienteActivo"(s."IdSistemaUsuario")
        )
        AND (
            NOT "Privada"
            OR "FSistemaUsuarioTieneRol"('ADMIN')
            OR "IdSistemaUsuario" IN (
                SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
            )
            OR EXISTS (
                SELECT 1 FROM "TClientePublicaciones" p
                JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
                JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
                WHERE p."IdClientePublicacion" = "TClientePublicacionesCondolencias"."IdClientePublicacion"
                  AND propietario."IdAuthSupabase" = auth.uid()
            )
        )
    );

-- ---------------------------------------------------------------------
-- 2. Vista de lectura: mismo criterio de visibilidad de arriba, más el nombre del autor ya
--    resuelto y oculto si la condolencia es anónima (salvo para el propio autor o ADMIN). Al
--    estar creada por el propietario de las tablas de origen, esta vista NO aplica el RLS de
--    "TClientePublicacionesCondolencias" ni el de "TSistemaUsuarios" (que solo deja ver el
--    nombre de clientes activos o de seguidores de la propia sede, no el de cualquier autor de
--    condolencia): la visibilidad y el enmascarado de nombre se repiten aquí explícitamente en
--    vez de depender de esas políticas.
-- ---------------------------------------------------------------------
CREATE VIEW "VClientePublicacionesCondolencias" AS
SELECT
    c."IdClientePublicacionCondolencia",
    c."IdClientePublicacion",
    c."IdSistemaUsuario",
    c."Texto",
    c."Anonima",
    c."Privada",
    c."FechaAlta",
    c."FechaModificacion",
    CASE
        WHEN c."Anonima" AND NOT (
            "FSistemaUsuarioTieneRol"('ADMIN')
            OR c."IdSistemaUsuario" IN (SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid())
        )
        THEN NULL
        ELSE u."Nombre"
    END AS "Nombre",
    CASE
        WHEN c."Anonima" AND NOT (
            "FSistemaUsuarioTieneRol"('ADMIN')
            OR c."IdSistemaUsuario" IN (SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid())
        )
        THEN NULL
        ELSE u."Apellido1"
    END AS "Apellido1"
FROM "TClientePublicacionesCondolencias" c
JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = c."IdSistemaUsuario"
WHERE
    EXISTS (
        SELECT 1 FROM "TClientePublicaciones" p
        JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
        WHERE p."IdClientePublicacion" = c."IdClientePublicacion"
          AND "FSistemaUsuarioEsClienteActivo"(s."IdSistemaUsuario")
    )
    AND (
        NOT c."Privada"
        OR "FSistemaUsuarioTieneRol"('ADMIN')
        OR c."IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM "TClientePublicaciones" p
            JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
            JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE p."IdClientePublicacion" = c."IdClientePublicacion"
              AND propietario."IdAuthSupabase" = auth.uid()
        )
    );

GRANT SELECT ON "VClientePublicacionesCondolencias" TO authenticated;

-- ---------------------------------------------------------------------
-- 3. Recuento sin restricciones de privacidad (cuenta TODAS, anónimas y privadas incluidas):
--    función SECURITY DEFINER de un uuid, más una variante "computed field" de PostgREST (recibe
--    la fila de "TClientePublicaciones") para poder pedirla como una columna más al listar el
--    Taboleiro desde la app.
-- ---------------------------------------------------------------------
CREATE FUNCTION "FSistemaContarCondolencias"(p_id_cliente_publicacion uuid)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT COUNT(*)::integer
    FROM "TClientePublicacionesCondolencias"
    WHERE "IdClientePublicacion" = p_id_cliente_publicacion;
$$;

CREATE FUNCTION "FSistemaContarCondolencias"("TClientePublicaciones")
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT "FSistemaContarCondolencias"($1."IdClientePublicacion");
$$;

GRANT EXECUTE ON FUNCTION "FSistemaContarCondolencias"(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION "FSistemaContarCondolencias"("TClientePublicaciones") TO authenticated;

-- ---------------------------------------------------------------------
-- 4. "FTablonPersonalizado" (045) y "FBuscarPublicacionesHistorico" (040) contaban las
--    condolencias con un subquery directo sobre la tabla: al llevar RLS ahora, ese subquery
--    dejaría fuera las privadas ajenas a quien mira el Taboleiro o busca. Se recrean con
--    "FSistemaContarCondolencias"(uuid), que la cuenta sin RLS. Mismas columnas de salida que
--    antes, así que un CREATE OR REPLACE basta (no hace falta DROP FUNCTION).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "FTablonPersonalizado"(
    p_offset integer,
    p_limit integer
)
RETURNS TABLE (
    "IdClientePublicacion" uuid,
    "IdClienteSede" uuid,
    "NombreFallecido" varchar,
    "FechaFallecimiento" date,
    "Edad" integer,
    "FechaFuneral" date,
    "HoraFuneral" time,
    "Iglesia" varchar,
    "Lugar" varchar,
    "CapillaArdiente" varchar,
    "Sala" varchar,
    "Observaciones" text,
    "FechaAlta" timestamptz,
    "NombreCliente" varchar,
    "NombreSede" varchar,
    "Concello" varchar,
    "Provincia" varchar,
    "NumCondolencias" integer
)
LANGUAGE sql
STABLE
AS $$
    WITH yo AS (
        SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
    )
    SELECT
        p."IdClientePublicacion",
        p."IdClienteSede",
        p."NombreFallecido",
        p."FechaFallecimiento",
        p."Edad",
        p."FechaFuneral",
        p."HoraFuneral",
        p."Iglesia",
        p."Lugar",
        p."CapillaArdiente",
        p."Sala",
        p."Observaciones",
        p."FechaAlta",
        u."Nombre" AS "NombreCliente",
        s."Nombre" AS "NombreSede",
        s."Concello",
        s."Provincia",
        "FSistemaContarCondolencias"(p."IdClientePublicacion") AS "NumCondolencias"
    FROM "TClientePublicaciones" p
    JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
    JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
    WHERE
        p."IdClienteSede" IN (
            SELECT "IdClienteSede" FROM "TClienteSeguimientos" WHERE "IdSistemaUsuario" = (SELECT "IdSistemaUsuario" FROM yo)
        )
        OR s."Concello" IN (
            SELECT "Concello" FROM "TSistemaUsuarioZonas" WHERE "IdSistemaUsuario" = (SELECT "IdSistemaUsuario" FROM yo)
        )
    ORDER BY p."FechaAlta" DESC
    OFFSET p_offset
    LIMIT p_limit;
$$;

GRANT EXECUTE ON FUNCTION "FTablonPersonalizado"(integer, integer) TO authenticated;

CREATE OR REPLACE FUNCTION "FBuscarPublicacionesHistorico"(
    p_termino text,
    p_offset integer,
    p_limit integer
)
RETURNS TABLE (
    "IdClientePublicacion" uuid,
    "IdClienteSede" uuid,
    "NombreFallecido" varchar,
    "FechaFallecimiento" date,
    "Edad" integer,
    "FechaFuneral" date,
    "HoraFuneral" time,
    "Iglesia" varchar,
    "Lugar" varchar,
    "CapillaArdiente" varchar,
    "Sala" varchar,
    "Observaciones" text,
    "FechaAlta" timestamptz,
    "NombreCliente" varchar,
    "NombreSede" varchar,
    "Concello" varchar,
    "Provincia" varchar,
    "NumCondolencias" integer
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p."IdClientePublicacion",
        p."IdClienteSede",
        p."NombreFallecido",
        p."FechaFallecimiento",
        p."Edad",
        p."FechaFuneral",
        p."HoraFuneral",
        p."Iglesia",
        p."Lugar",
        p."CapillaArdiente",
        p."Sala",
        p."Observaciones",
        p."FechaAlta",
        u."Nombre" AS "NombreCliente",
        s."Nombre" AS "NombreSede",
        s."Concello",
        s."Provincia",
        "FSistemaContarCondolencias"(p."IdClientePublicacion") AS "NumCondolencias"
    FROM "TClientePublicaciones" p
    JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
    JOIN "TSistemaUsuarios" u ON u."IdSistemaUsuario" = s."IdSistemaUsuario"
    WHERE
        p."NombreFallecido" ILIKE '%' || p_termino || '%'
        OR p."Iglesia" ILIKE '%' || p_termino || '%'
        OR p."Lugar" ILIKE '%' || p_termino || '%'
        OR p."CapillaArdiente" ILIKE '%' || p_termino || '%'
        OR p."Sala" ILIKE '%' || p_termino || '%'
        OR p."Observaciones" ILIKE '%' || p_termino || '%'
        OR u."Nombre" ILIKE '%' || p_termino || '%'
        OR s."Concello" ILIKE '%' || p_termino || '%'
    ORDER BY p."FechaAlta" DESC
    OFFSET p_offset
    LIMIT p_limit;
$$;

GRANT EXECUTE ON FUNCTION "FBuscarPublicacionesHistorico"(text, integer, integer) TO authenticated;
