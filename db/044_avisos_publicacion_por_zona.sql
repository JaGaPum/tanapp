-- =====================================================================
-- 044 - Avisos de "publicación nueva" también para quien sigue la zona (no solo la sede)
-- =====================================================================
-- El trigger de 024 ("FSistemaCrearAvisosPublicacion") solo avisaba a quien sigue la sede en
-- concreto (TClienteSeguimientos). Desde 038, un usuario puede seguir un concello entero y
-- recibir los "TClienteAvisos" (avisos manuales del cliente) de cualquier sede de esa zona, pero
-- se quedó fuera el aviso automático de "hay una esquela nueva" (TSistemaAvisos), que es el que
-- de verdad se usa casi siempre. Aquí se añade esa misma vía también a este trigger.
-- Requiere que 038 ya esté aplicado.

-- Necesario para el "ON CONFLICT" de más abajo: un mismo usuario puede calificar ahora por dos
-- vías (seguidor directo de la sede y seguidor de la zona) para el mismo aviso de publicación;
-- sin esta unicidad le llegarían dos filas (y dos push) en vez de una.
CREATE UNIQUE INDEX "UX_TSistemaAvisos_Usuario_Publicacion" ON "TSistemaAvisos" ("IdSistemaUsuario", "IdClientePublicacion");

CREATE OR REPLACE FUNCTION "FSistemaCrearAvisosPublicacion"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_concello varchar(150);
BEGIN
    SELECT "Concello" INTO v_concello FROM "TClienteSedes" WHERE "IdClienteSede" = NEW."IdClienteSede";

    INSERT INTO "TSistemaAvisos" ("IdSistemaUsuario", "IdClientePublicacion")
    SELECT "IdSistemaUsuario", NEW."IdClientePublicacion"
    FROM "TClienteSeguimientos"
    WHERE "IdClienteSede" = NEW."IdClienteSede"
    ON CONFLICT ("IdSistemaUsuario", "IdClientePublicacion") DO NOTHING;

    INSERT INTO "TSistemaAvisos" ("IdSistemaUsuario", "IdClientePublicacion")
    SELECT "IdSistemaUsuario", NEW."IdClientePublicacion"
    FROM "TSistemaUsuarioZonas"
    WHERE "Concello" = v_concello
    ON CONFLICT ("IdSistemaUsuario", "IdClientePublicacion") DO NOTHING;

    RETURN NEW;
END;
$$;
