-- =====================================================================
-- 069 - El cliente configura, por esquela, si admite condolencias y si son privadas
-- =====================================================================
-- Hasta ahora toda esquela admitía condolencias, y cada seguidor decidía por su cuenta si la
-- suya era "Privada" (049, solo la ve el cliente). Ahora el propio cliente puede, al publicar
-- una esquela, decidir de antemano que NO admite condolencias en absoluto, o que las admite pero
-- TODAS han de ser privadas (sin que cada seguidor tenga que marcarlo él mismo). Un acto (misa u
-- otro, 064) nunca admite condolencias, tenga lo que tenga esta columna: no es un fallecimiento
-- recién ocurrido, no tiene sentido "dar el pésame" ahí.
--
-- "CondolenciasSoloPrivadas" es un concepto DISTINTO del "Privada" de 049 (esa sigue siendo la
-- de cada condolencia individual): esta nueva columna vive en la publicación, no en la
-- condolencia, y cuando está activa OBLIGA a que "Privada" salga true en cada una, sin que el
-- seguidor pueda elegir lo contrario -de ahí el trigger de más abajo, para que esto se cumpla
-- también si alguien escribe directo a la tabla saltándose el formulario-.
--
-- Requiere que 049 y 064 ya estén aplicados.

ALTER TABLE "TClientePublicaciones"
    ADD COLUMN "AdmiteCondolencias" boolean NOT NULL DEFAULT true,
    ADD COLUMN "CondolenciasSoloPrivadas" boolean NOT NULL DEFAULT false;

ALTER TABLE "TClientePublicacionesProgramadas"
    ADD COLUMN "AdmiteCondolencias" boolean NOT NULL DEFAULT true,
    ADD COLUMN "CondolenciasSoloPrivadas" boolean NOT NULL DEFAULT false;

-- Cambia el cuerpo, no la firma: un CREATE OR REPLACE simple vale (mismo motivo que en 064).
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
        "Sala", "Observaciones", "Tipo", "IdConfiguracionActoTipo", "ActoTipoOtro",
        "AdmiteCondolencias", "CondolenciasSoloPrivadas"
    )
    SELECT
        "IdClienteSede", "NombreFallecido", "FechaFallecimiento", "Edad",
        "FechaFuneral", "HoraFuneral", "Iglesia", "Lugar", "CapillaArdiente",
        "Sala", "Observaciones", "Tipo", "IdConfiguracionActoTipo", "ActoTipoOtro",
        "AdmiteCondolencias", "CondolenciasSoloPrivadas"
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
-- Aplica las dos reglas de arriba también si alguien escribe directo a la tabla (saltándose la
-- app): sin SECURITY DEFINER, ya que solo lee "TClientePublicaciones" -algo que quien inserta la
-- condolencia ya puede leer igualmente por su propia policy de SELECT (017)-.
-- =====================================================================
CREATE OR REPLACE FUNCTION "FSistemaValidarCondolencia"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo varchar(20);
    v_admite boolean;
    v_solo_privadas boolean;
BEGIN
    SELECT "Tipo", "AdmiteCondolencias", "CondolenciasSoloPrivadas"
        INTO v_tipo, v_admite, v_solo_privadas
        FROM "TClientePublicaciones"
        WHERE "IdClientePublicacion" = NEW."IdClientePublicacion";

    IF v_tipo IS DISTINCT FROM 'ESQUELA' OR NOT v_admite THEN
        RAISE EXCEPTION 'Esta publicación no admite condolencias';
    END IF;

    IF v_solo_privadas THEN
        NEW."Privada" := true;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_FSistemaValidarCondolencia"
    BEFORE INSERT OR UPDATE ON "TClientePublicacionesCondolencias"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaValidarCondolencia"();
