-- =====================================================================
-- 060 - Términos por rol (CLIENTE vs USUARIO_ORDINARIO) + qué texto exacto aceptó cada usuario
-- =====================================================================
-- Dos cambios relacionados con "TSistemaTerminos"/"TSistemaTerminosAceptaciones" (026, 051):
--
-- 1. Hasta ahora cada "Tipo" (TERMINOS_USO/PRIVACIDAD) tenía como mucho UN documento activo,
--    compartido por todos los roles (051 fusionó en uno solo el de CLIENTE y el de
--    USUARIO_ORDINARIO). El admin necesita ahora poder tener contenido distinto para cada rol
--    (p. ej. unos términos de uso para quien publica esquelas y otros para quien solo las
--    consulta/sigue/deja condolencias). Se añade "Rol" y el documento activo pasa a ser único
--    por (Tipo, Rol) en vez de por Tipo a secas. Los documentos activos de hoy se duplican (una
--    copia para CLIENTE, otra para USUARIO_ORDINARIO, mismo contenido de partida) para que nadie
--    se quede sin términos mientras el admin no los edite a mano y los diferencie.
--
-- 2. Hasta ahora "TSistemaTerminosAceptaciones" solo apuntaba (FK) al documento: si el admin
--    editaba después el título/cuerpo (edición en el sitio, sin crear versión nueva -ver
--    EditarTerminosScreen-), la fila de aceptación pasaba a "significar" un texto que el usuario
--    nunca llegó a leer. Se añade una copia del título/cuerpo/idioma tal cual estaban en el
--    momento de aceptar, para poder consultar después exactamente qué aceptó cada uno. Nula en
--    las aceptaciones ya existentes (no hay forma de reconstruir qué texto vieron entonces).
--
-- Requiere que 026 y 051 ya estén aplicados.

-- ---------------------------------------------------------------------
-- 1. Términos por rol
-- ---------------------------------------------------------------------
ALTER TABLE "TSistemaTerminos"
    ADD COLUMN "Rol" varchar(20) NULL
        CHECK ("Rol" IN ('CLIENTE', 'USUARIO_ORDINARIO'));

-- Hay que quitar de en medio los índices viejos (únicos por Tipo a secas) ANTES de duplicar
-- cada documento en dos filas del mismo Tipo+Version+Activo=true: si no, la propia duplicación
-- viola esas reglas antiguas, que son justo las que se están sustituyendo.
DROP INDEX "UX_TSistemaTerminos_Tipo_Activo";
DROP INDEX "UX_TSistemaTerminos_Tipo_Version";

DO $$
DECLARE
    doc RECORD;
    nuevo_id uuid;
    rol_nuevo text;
BEGIN
    FOR doc IN SELECT * FROM "TSistemaTerminos" WHERE "Activo" = true AND "Rol" IS NULL LOOP
        FOREACH rol_nuevo IN ARRAY ARRAY['CLIENTE', 'USUARIO_ORDINARIO'] LOOP
            INSERT INTO "TSistemaTerminos" ("Tipo", "Version", "Activo", "Rol")
            VALUES (doc."Tipo", doc."Version", true, rol_nuevo)
            RETURNING "IdSistemaTermino" INTO nuevo_id;

            INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
            SELECT nuevo_id, "IdSistemaIdioma", "Titulo", "Cuerpo"
            FROM "TSistemaTerminosIdiomas"
            WHERE "IdSistemaTermino" = doc."IdSistemaTermino";
        END LOOP;

        UPDATE "TSistemaTerminos" SET "Activo" = false WHERE "IdSistemaTermino" = doc."IdSistemaTermino";
    END LOOP;
END $$;

-- "Rol" se queda NULLABLE a propósito: los documentos ya desactivados (versiones anteriores,
-- incluida la propia fila original que se acaba de desactivar arriba) son de antes de que
-- existiera esta distinción y no hay forma de asignarles un rol con sentido. Lo único que
-- importa es que todo documento ACTIVO tenga uno, y eso ya lo garantizan tanto el código (la
-- app siempre lo manda al crear/editar) como el índice único de abajo.
CREATE UNIQUE INDEX "UX_TSistemaTerminos_Tipo_Rol_Activo"
    ON "TSistemaTerminos" ("Tipo", "Rol") WHERE "Activo";
CREATE UNIQUE INDEX "UX_TSistemaTerminos_Tipo_Rol_Version"
    ON "TSistemaTerminos" ("Tipo", "Rol", "Version");

-- ---------------------------------------------------------------------
-- 2. Snapshot de qué texto exacto (y en qué idioma) aceptó cada usuario
-- ---------------------------------------------------------------------
ALTER TABLE "TSistemaTerminosAceptaciones"
    ADD COLUMN "IdSistemaIdioma" uuid NULL,
    ADD COLUMN "Titulo" varchar(200) NULL,
    ADD COLUMN "Cuerpo" text NULL;

ALTER TABLE "TSistemaTerminosAceptaciones"
    ADD CONSTRAINT "FK_TSistemaTerminosAceptaciones_IdSistemaIdioma"
        FOREIGN KEY ("IdSistemaIdioma")
        REFERENCES "TSistemaIdiomas" ("IdSistemaIdioma")
        ON DELETE RESTRICT;
