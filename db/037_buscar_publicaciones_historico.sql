-- =====================================================================
-- 037 - Búsqueda de publicaciones sobre todo el histórico (no solo lo ya cargado)
-- =====================================================================
-- El Taboleiro filtraba en Dart sobre las publicaciones ya paginadas en memoria: quien buscara
-- un nombre antiguo, no cargado todavía en pantalla, no lo encontraba. Esta función hace la
-- búsqueda en SQL sobre toda la tabla, paginada igual que "listTodas" en el repositorio.
--
-- Sin SECURITY DEFINER a propósito: se ejecuta como el rol "authenticated" que hace la llamada,
-- así que las políticas RLS de "TClientePublicaciones"/"TClienteSedes"/"TSistemaUsuarios" se
-- aplican exactamente igual que en un SELECT normal con estas mismas tablas embebidas.

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
    "Provincia" varchar
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
        s."Provincia"
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
