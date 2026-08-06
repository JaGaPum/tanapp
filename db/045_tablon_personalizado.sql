-- =====================================================================
-- 045 - El Taboleiro deja de ser el tablón global: solo esquelas de clientes seguidos o de
--        zonas seguidas
-- =====================================================================
-- Hasta ahora "listTodas" devolvía todas las publicaciones de todos los clientes activos, sin
-- ningún filtro por seguimiento (la RLS solo exige que el cliente esté activo). A partir de
-- ahora el Taboleiro es personal: cada usuario solo ve las esquelas de los clientes que sigue
-- (TClienteSeguimientos) o de clientes con sede en una zona que sigue (TSistemaUsuarioZonas).
--
-- Se resuelve el usuario llamante con auth.uid() dentro de la propia función (no se recibe como
-- parámetro) para que nadie pueda pedir el tablón personalizado de otro usuario pasando su id.
-- Sin SECURITY DEFINER a propósito: se ejecuta como el rol "authenticated" que llama, así que
-- las políticas RLS de todas las tablas involucradas se aplican igual que en un SELECT normal.
-- Mismo formato de fila plana que "FBuscarPublicacionesHistorico" (037/040), para poder
-- reutilizar "PublicacionConSede.fromSearchRow" tal cual en la app.
-- Requiere que 038 ya esté aplicado.

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
        (
            SELECT COUNT(*)::integer
            FROM "TClientePublicacionesCondolencias" c
            WHERE c."IdClientePublicacion" = p."IdClientePublicacion"
        ) AS "NumCondolencias"
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
