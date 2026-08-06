-- =====================================================================
-- 040 - Añade el número de condolencias a los resultados de "FBuscarPublicacionesHistorico"
-- =====================================================================
-- Las tarjetas de esquela ahora muestran cuántas condolencias tiene cada una (037/038); el
-- listado normal del Taboleiro lo consigue con un embed "TClientePublicacionesCondolencias(count)"
-- de PostgREST, pero el RPC de búsqueda histórica no pasa por PostgREST embeds, así que necesita
-- su propia columna. Cambiar las columnas de salida de una función exige recrearla entera (un
-- simple CREATE OR REPLACE no vale si cambia el "RETURNS TABLE").
-- Requiere que 037 ya esté aplicado.

DROP FUNCTION IF EXISTS "FBuscarPublicacionesHistorico"(text, integer, integer);

CREATE FUNCTION "FBuscarPublicacionesHistorico"(
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
        (
            SELECT COUNT(*)::integer
            FROM "TClientePublicacionesCondolencias" c
            WHERE c."IdClientePublicacion" = p."IdClientePublicacion"
        ) AS "NumCondolencias"
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
