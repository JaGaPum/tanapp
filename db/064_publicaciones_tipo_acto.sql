-- =====================================================================
-- 064 - Publicaciones de tipo "Acto" (misa de cabo de ano, aniversario, a intención de
--        alguén...), además de la esquela de siempre
-- =====================================================================
-- Hasta ahora "TClientePublicaciones" era siempre una esquela (fallecimiento + velorio +
-- funeral). Un cliente puede publicar también un "acto" (misa u otro acto de recuerdo, religioso
-- o no) que no acompaña a un fallecimiento recién ocurrido, sino que lo recuerda tiempo después
-- -o a petición de alguien-: reutiliza la MISMA tabla y el mismo tablón/seguidos/avisos push que
-- ya tiene la esquela (así quien sigue a ese cliente se entera igual), añadiendo solo una columna
-- "Tipo" para distinguirlas y, para el acto, un tipo de entre un catálogo editable por el ADMIN
-- (para no tener que tocar código cada vez que aparece un caso nuevo, religioso o no).
--
-- Requiere que 025 (FechaFuneral/HoraFuneral) y 056 (cron de programadas) ya estén aplicados.

-- =====================================================================
-- 1. Catálogo de tipos de acto, editable por el ADMIN. Un único "Nombre" (sin traducción por
--    idioma): mismo criterio que ya se usa de hecho con "TConfiguracionClienteTipos" (010), cuyo
--    nombre se muestra tal cual en toda la app pese a tener también una tabla de traducciones.
-- =====================================================================
CREATE TABLE "TConfiguracionActoTipos" (
    "IdConfiguracionActoTipo" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Nombre" varchar(100) NOT NULL,
    "Activo" boolean NOT NULL DEFAULT true,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TConfiguracionActoTipos_Nombre" ON "TConfiguracionActoTipos" ("Nombre");

ALTER TABLE "TConfiguracionActoTipos" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionActoTipos"
    BEFORE UPDATE ON "TConfiguracionActoTipos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE POLICY "select_autenticado_TConfiguracionActoTipos" ON "TConfiguracionActoTipos"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionActoTipos" ON "TConfiguracionActoTipos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

INSERT INTO "TConfiguracionActoTipos" ("Nombre") VALUES
    ('Misa de cabo de ano'),
    ('Misa de aniversario'),
    ('Misa de mes'),
    ('Misa a intención de alguén'),
    ('Acto civil de recordo')
ON CONFLICT ("Nombre") DO NOTHING;

-- =====================================================================
-- 2. "Tipo" + tipo de acto en la tabla real y en la de programadas (055): mismas columnas en las
--    dos, para que el job de cron (056, más abajo) pueda copiarlas tal cual al publicar.
-- =====================================================================
ALTER TABLE "TClientePublicaciones"
    ADD COLUMN "Tipo" varchar(20) NOT NULL DEFAULT 'ESQUELA'
        CHECK ("Tipo" IN ('ESQUELA', 'ACTO')),
    ADD COLUMN "IdConfiguracionActoTipo" uuid NULL,
    ADD COLUMN "ActoTipoOtro" varchar(200) NULL;

ALTER TABLE "TClientePublicaciones"
    ADD CONSTRAINT "FK_TClientePublicaciones_IdConfiguracionActoTipo"
        FOREIGN KEY ("IdConfiguracionActoTipo")
        REFERENCES "TConfiguracionActoTipos" ("IdConfiguracionActoTipo")
        ON DELETE SET NULL;

ALTER TABLE "TClientePublicacionesProgramadas"
    ADD COLUMN "Tipo" varchar(20) NOT NULL DEFAULT 'ESQUELA'
        CHECK ("Tipo" IN ('ESQUELA', 'ACTO')),
    ADD COLUMN "IdConfiguracionActoTipo" uuid NULL,
    ADD COLUMN "ActoTipoOtro" varchar(200) NULL;

ALTER TABLE "TClientePublicacionesProgramadas"
    ADD CONSTRAINT "FK_TClientePublicacionesProgramadas_IdConfiguracionActoTipo"
        FOREIGN KEY ("IdConfiguracionActoTipo")
        REFERENCES "TConfiguracionActoTipos" ("IdConfiguracionActoTipo")
        ON DELETE SET NULL;

-- =====================================================================
-- 3. Job de cron (056): copiar también las 3 columnas nuevas al mover de "...Programadas" a la
--    tabla real. Cambia el cuerpo, no la firma, así que un CREATE OR REPLACE simple vale.
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaPublicarProgramadas"()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO "TClientePublicaciones" (
        "IdClienteSede", "NombreFallecido", "FechaFallecimiento", "Edad",
        "FechaFuneral", "HoraFuneral", "Iglesia", "Lugar", "CapillaArdiente",
        "Sala", "Observaciones", "Tipo", "IdConfiguracionActoTipo", "ActoTipoOtro"
    )
    SELECT
        "IdClienteSede", "NombreFallecido", "FechaFallecimiento", "Edad",
        "FechaFuneral", "HoraFuneral", "Iglesia", "Lugar", "CapillaArdiente",
        "Sala", "Observaciones", "Tipo", "IdConfiguracionActoTipo", "ActoTipoOtro"
    FROM "TClientePublicacionesProgramadas"
    WHERE "FechaProgramada" <= now();

    DELETE FROM "TClientePublicacionesProgramadas" WHERE "FechaProgramada" <= now();

    INSERT INTO "TClienteAvisos" ("IdClienteSede", "Titulo", "Texto")
    SELECT "IdClienteSede", "Titulo", "Texto"
    FROM "TClienteAvisosProgramados"
    WHERE "FechaProgramada" <= now();

    DELETE FROM "TClienteAvisosProgramados" WHERE "FechaProgramada" <= now();
END;
$$;

-- =====================================================================
-- 4. RPCs de fila plana (Taboleiro y búsqueda histórica): cambian las columnas de salida, así
--    que hay que recrearlas enteras (mismo motivo que en 040).
-- =====================================================================
DROP FUNCTION IF EXISTS "FTablonPersonalizado"(integer, integer);

CREATE FUNCTION "FTablonPersonalizado"(
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
    "NumCondolencias" integer,
    "Tipo" varchar,
    "IdConfiguracionActoTipo" uuid,
    "ActoTipoOtro" varchar
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
        ) AS "NumCondolencias",
        p."Tipo",
        p."IdConfiguracionActoTipo",
        p."ActoTipoOtro"
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
    "NumCondolencias" integer,
    "Tipo" varchar,
    "IdConfiguracionActoTipo" uuid,
    "ActoTipoOtro" varchar
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
        ) AS "NumCondolencias",
        p."Tipo",
        p."IdConfiguracionActoTipo",
        p."ActoTipoOtro"
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
