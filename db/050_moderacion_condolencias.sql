-- =====================================================================
-- 050 - Moderación de condolencias por el cliente dueño de la esquela
-- =====================================================================
-- El cliente que publicó una esquela puede moderar las condolencias que recibe:
--   - Eliminarla (borrado lógico: deja de contarse y de verse por nadie salvo el propio autor,
--     a quien se le muestra un aviso de que se ha retirado por moderación, en vez de desaparecer
--     sin más explicación).
--   - Editar su texto (p. ej. para quitar una parte inapropiada sin borrarla entera): el nuevo
--     texto se ve con normalidad, pero al propio autor se le avisa de que el cliente la modificó.
-- Requiere que 049 ya esté aplicado.

ALTER TABLE "TClientePublicacionesCondolencias"
    ADD COLUMN "ModeradaOculta" boolean NOT NULL DEFAULT false,
    ADD COLUMN "ModeradaEditada" boolean NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------
-- 1. RLS: el dueño de la sede de la publicación puede actualizar (ocultar/editar) cualquier
--    condolencia de sus propias esquelas, además de que cada usuario ya podía actualizar la
--    suya propia (036) -son políticas permisivas independientes, se combinan con OR-.
-- ---------------------------------------------------------------------
CREATE POLICY "update_moderacion_dueno_TClientePublicacionesCondolencias" ON "TClientePublicacionesCondolencias"
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM "TClientePublicaciones" p
            JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
            JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE p."IdClientePublicacion" = "TClientePublicacionesCondolencias"."IdClientePublicacion"
              AND propietario."IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "TClientePublicaciones" p
            JOIN "TClienteSedes" s ON s."IdClienteSede" = p."IdClienteSede"
            JOIN "TSistemaUsuarios" propietario ON propietario."IdSistemaUsuario" = s."IdSistemaUsuario"
            WHERE p."IdClientePublicacion" = "TClientePublicacionesCondolencias"."IdClientePublicacion"
              AND propietario."IdAuthSupabase" = auth.uid()
        )
    );

-- ---------------------------------------------------------------------
-- 2. Vista de lectura (049): oculta a todo el mundo salvo al propio autor (o ADMIN) las
--    condolencias con "ModeradaOculta" -mismo patrón que ya usa para "Privada"-, y expone las
--    dos columnas nuevas para que la app pueda mostrar el aviso de moderación.
-- ---------------------------------------------------------------------
DROP VIEW "VClientePublicacionesCondolencias";

CREATE VIEW "VClientePublicacionesCondolencias" AS
SELECT
    c."IdClientePublicacionCondolencia",
    c."IdClientePublicacion",
    c."IdSistemaUsuario",
    c."Texto",
    c."Anonima",
    c."Privada",
    c."ModeradaOculta",
    c."ModeradaEditada",
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
    )
    AND (
        NOT c."ModeradaOculta"
        OR "FSistemaUsuarioTieneRol"('ADMIN')
        OR c."IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

GRANT SELECT ON "VClientePublicacionesCondolencias" TO authenticated;

-- ---------------------------------------------------------------------
-- 3. Recuento (049): las ocultas por moderación ya no cuentan como condolencia "viva".
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "FSistemaContarCondolencias"(p_id_cliente_publicacion uuid)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT COUNT(*)::integer
    FROM "TClientePublicacionesCondolencias"
    WHERE "IdClientePublicacion" = p_id_cliente_publicacion
      AND NOT "ModeradaOculta";
$$;
