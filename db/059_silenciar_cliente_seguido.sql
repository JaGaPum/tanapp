-- =====================================================================
-- 059 - Silenciar un cliente seguido (sin dejar de seguirlo)
-- =====================================================================
-- Un USUARIO_ORDINARIO puede querer seguir viendo a un cliente en "Seguindo" (esquelas en el
-- Taboleiro, poder consultar su histórico...) pero sin recibir el aviso/push de cada
-- publicación o aviso manual suyo. Antes la única forma de dejar de recibir avisos era dejar de
-- seguir del todo.
--
-- Solo afecta al seguimiento directo de una sede (TClienteSeguimientos); seguir una zona entera
-- (TSistemaUsuarioZonas, 038) es otro mecanismo y no tiene un cliente concreto que silenciar.
--
-- Requiere que 044 ya esté aplicado.

ALTER TABLE "TClienteSeguimientos"
    ADD COLUMN "Silenciado" boolean NOT NULL DEFAULT false;

-- No existía policy de UPDATE (antes esta tabla solo se insertaba/borraba, nunca se modificaba).
CREATE POLICY "update_propio_TClienteSeguimientos" ON "TClienteSeguimientos"
    FOR UPDATE TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    )
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- Excluye a quien tiene silenciada la sede del aviso automático de "publicación nueva". La vía
-- de zona (TSistemaUsuarioZonas) no se toca: silenciar es por cliente, no aplica ahí.
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
      AND NOT "Silenciado"
    ON CONFLICT ("IdSistemaUsuario", "IdClientePublicacion") DO NOTHING;

    INSERT INTO "TSistemaAvisos" ("IdSistemaUsuario", "IdClientePublicacion")
    SELECT "IdSistemaUsuario", NEW."IdClientePublicacion"
    FROM "TSistemaUsuarioZonas"
    WHERE "Concello" = v_concello
    ON CONFLICT ("IdSistemaUsuario", "IdClientePublicacion") DO NOTHING;

    RETURN NEW;
END;
$$;

-- Mismo criterio para el buzón de un aviso manual del cliente (TClienteAvisos).
CREATE OR REPLACE FUNCTION "FSistemaCrearDestinatariosClienteAviso"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_concello varchar(150);
BEGIN
    SELECT "Concello" INTO v_concello FROM "TClienteSedes" WHERE "IdClienteSede" = NEW."IdClienteSede";

    INSERT INTO "TClienteAvisosDestinatarios" ("IdClienteAviso", "IdSistemaUsuario")
    SELECT NEW."IdClienteAviso", "IdSistemaUsuario"
    FROM "TClienteSeguimientos"
    WHERE "IdClienteSede" = NEW."IdClienteSede"
      AND NOT "Silenciado"
    ON CONFLICT ("IdClienteAviso", "IdSistemaUsuario") DO NOTHING;

    INSERT INTO "TClienteAvisosDestinatarios" ("IdClienteAviso", "IdSistemaUsuario")
    SELECT NEW."IdClienteAviso", "IdSistemaUsuario"
    FROM "TSistemaUsuarioZonas"
    WHERE "Concello" = v_concello
    ON CONFLICT ("IdClienteAviso", "IdSistemaUsuario") DO NOTHING;

    RETURN NEW;
END;
$$;
