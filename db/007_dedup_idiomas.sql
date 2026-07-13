-- =====================================================================
-- 007 - Deduplica TSistemaIdiomas
-- =====================================================================
-- La migración 006 insertó 'ES'/'GL' en TSistemaIdiomas comprobando solo el
-- código, sin saber que la tabla ya tenía Español/Galego dados de alta con
-- otros códigos. Resultado: dos filas "Español" y dos "Galego", y por eso en
-- Configuración > Comunicaciones aparecían 4 bloques (2 por idioma) en vez
-- de 1. Esta migración fusiona los duplicados (por nombre, ignorando mayúsculas
-- y espacios) conservando la fila más antigua y reasignando cualquier
-- referencia (idioma preferido de usuario, traducciones de comunicaciones) a
-- esa fila antes de borrar la duplicada.
-- Requiere que 006 ya esté aplicado.

DO $$
DECLARE
    fila record;
BEGIN
    FOR fila IN
        SELECT lower(trim("Nombre")) AS clave, array_agg("IdSistemaIdioma" ORDER BY "FechaAlta", "IdSistemaIdioma") AS ids
        FROM "TSistemaIdiomas"
        GROUP BY lower(trim("Nombre"))
        HAVING count(*) > 1
    LOOP
        DECLARE
            id_canonico uuid := fila.ids[1];
            id_duplicado uuid;
        BEGIN
            FOREACH id_duplicado IN ARRAY fila.ids[2:array_length(fila.ids, 1)]
            LOOP
                UPDATE "TSistemaUsuarios"
                SET "IdSistemaIdiomaPreferido" = id_canonico
                WHERE "IdSistemaIdiomaPreferido" = id_duplicado;

                -- Reasigna traducciones que no choquen con una ya existente para el idioma canónico
                UPDATE "TConfiguracionComunicacionesIdiomas" t
                SET "IdSistemaIdioma" = id_canonico
                WHERE t."IdSistemaIdioma" = id_duplicado
                  AND NOT EXISTS (
                      SELECT 1 FROM "TConfiguracionComunicacionesIdiomas" t2
                      WHERE t2."IdConfiguracionComunicacion" = t."IdConfiguracionComunicacion"
                        AND t2."IdSistemaIdioma" = id_canonico
                  );

                -- Las que sí chocan (ya había traducción en el canónico) se descartan
                DELETE FROM "TConfiguracionComunicacionesIdiomas" WHERE "IdSistemaIdioma" = id_duplicado;

                DELETE FROM "TSistemaIdiomas" WHERE "IdSistemaIdioma" = id_duplicado;
            END LOOP;
        END;
    END LOOP;
END $$;

-- Evita que esto vuelva a pasar: código de idioma único.
CREATE UNIQUE INDEX IF NOT EXISTS "UX_TSistemaIdiomas_Codigo" ON "TSistemaIdiomas" ("Codigo");
