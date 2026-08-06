-- =====================================================================
-- 038 - Avisos por zona, sin necesidad de seguir a un cliente concreto
-- =====================================================================
-- Hasta ahora solo llegaba un aviso de "TClienteAvisos" a quien siguiera esa sede en concreto
-- (TClienteSeguimientos). Con esto, un usuario puede además "seguir" un concello entero (p.ej.
-- el suyo) y recibir los avisos de cualquier cliente con sede en ese concello, sin tener que
-- localizar y seguir a cada cliente uno a uno.
-- Requiere que 031 ya esté aplicado (tabla "TClienteAvisos"/"TClienteAvisosDestinatarios" y el
-- trigger "FSistemaCrearDestinatariosClienteAviso").

CREATE TABLE "TSistemaUsuarioZonas" (
    "IdSistemaUsuarioZona" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "Provincia" varchar(150) NOT NULL,
    "Concello" varchar(150) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaUsuarioZonas"
    ADD CONSTRAINT "FK_TSistemaUsuarioZonas_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE;

-- "Concello" es lo único que hace falta para el fan-out (coincide tal cual con
-- "TClienteSedes"."Concello"); se guarda también "Provincia" solo para poder mostrarla en la
-- app sin tener que volver a resolverla contra el catálogo de configuración.
CREATE UNIQUE INDEX "UX_TSistemaUsuarioZonas_Usuario_Concello" ON "TSistemaUsuarioZonas" ("IdSistemaUsuario", "Concello");
CREATE INDEX "IX_TSistemaUsuarioZonas_Concello" ON "TSistemaUsuarioZonas" ("Concello");

ALTER TABLE "TSistemaUsuarioZonas" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "mutacion_propia_TSistemaUsuarioZonas" ON "TSistemaUsuarioZonas"
    FOR ALL TO authenticated
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

-- Se sustituye el trigger de 031 para que, además de a los seguidores de la sede, cree buzón
-- también a quien siga el concello de esa sede. El "ON CONFLICT DO NOTHING" evita duplicar el
-- buzón de quien siga a la vez la sede y su concello (violaría el UNIQUE de 031 sin él).
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
    ON CONFLICT ("IdClienteAviso", "IdSistemaUsuario") DO NOTHING;

    INSERT INTO "TClienteAvisosDestinatarios" ("IdClienteAviso", "IdSistemaUsuario")
    SELECT NEW."IdClienteAviso", "IdSistemaUsuario"
    FROM "TSistemaUsuarioZonas"
    WHERE "Concello" = v_concello
    ON CONFLICT ("IdClienteAviso", "IdSistemaUsuario") DO NOTHING;

    RETURN NEW;
END;
$$;
