-- =====================================================================
-- 010 - Configuración > Tipos de Cliente (Funeraria/Tanatorio/Eclesiástico),
--        asignable en la ficha de usuario y al aprobar una solicitud de cliente
-- =====================================================================
-- Requiere que 009 ya esté aplicado.

-- =====================================================================
-- 1. Tablas: TConfiguracionClienteTipos + traducciones por idioma
-- =====================================================================
CREATE TABLE "TConfiguracionClienteTipos" (
    "IdConfiguracionClienteTipo" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Nombre" varchar(100) NOT NULL,
    "Activo" boolean NOT NULL DEFAULT true,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TConfiguracionClienteTipos_Nombre" ON "TConfiguracionClienteTipos" ("Nombre");

CREATE TABLE "TConfiguracionClienteTiposIdiomas" (
    "IdConfiguracionClienteTipoIdioma" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdConfiguracionClienteTipo" uuid NOT NULL,
    "IdSistemaIdioma" uuid NOT NULL,
    "Nombre" varchar(100) NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TConfiguracionClienteTiposIdiomas"
    ADD CONSTRAINT "FK_TConfiguracionClienteTiposIdiomas_IdConfiguracionClienteTipo"
        FOREIGN KEY ("IdConfiguracionClienteTipo")
        REFERENCES "TConfiguracionClienteTipos" ("IdConfiguracionClienteTipo")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TConfiguracionClienteTiposIdiomas_IdSistemaIdioma"
        FOREIGN KEY ("IdSistemaIdioma")
        REFERENCES "TSistemaIdiomas" ("IdSistemaIdioma")
        ON DELETE RESTRICT;

CREATE UNIQUE INDEX "UX_TConfiguracionClienteTiposIdiomas_Tipo_Idioma"
    ON "TConfiguracionClienteTiposIdiomas" ("IdConfiguracionClienteTipo", "IdSistemaIdioma");

ALTER TABLE "TConfiguracionClienteTipos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TConfiguracionClienteTiposIdiomas" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionClienteTipos"
    BEFORE UPDATE ON "TConfiguracionClienteTipos"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionClienteTiposIdiomas"
    BEFORE UPDATE ON "TConfiguracionClienteTiposIdiomas"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- =====================================================================
-- 2. RLS: lectura para cualquier autenticado (lo usan los desplegables de la
--    ficha de Usuario y de aprobación de Solicitud); mutación solo ADMIN
-- =====================================================================
CREATE POLICY "select_autenticado_TConfiguracionClienteTipos" ON "TConfiguracionClienteTipos"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionClienteTipos" ON "TConfiguracionClienteTipos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "select_autenticado_TConfiguracionClienteTiposIdiomas" ON "TConfiguracionClienteTiposIdiomas"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "mutacion_admin_TConfiguracionClienteTiposIdiomas" ON "TConfiguracionClienteTiposIdiomas"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- 3. TSistemaUsuarios: tipo de cliente asignado (editable en su ficha)
-- =====================================================================
ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "IdConfiguracionClienteTipo" uuid NULL;

ALTER TABLE "TSistemaUsuarios"
    ADD CONSTRAINT "FK_TSistemaUsuarios_IdConfiguracionClienteTipo"
        FOREIGN KEY ("IdConfiguracionClienteTipo")
        REFERENCES "TConfiguracionClienteTipos" ("IdConfiguracionClienteTipo")
        ON DELETE SET NULL;

-- =====================================================================
-- 4. TClienteSolicitudes: tipo elegido por el ADMIN al aprobar; la Edge
--    Function aprobar-solicitud-cliente lo copia al usuario que crea
-- =====================================================================
ALTER TABLE "TClienteSolicitudes"
    ADD COLUMN "IdConfiguracionClienteTipo" uuid NULL;

ALTER TABLE "TClienteSolicitudes"
    ADD CONSTRAINT "FK_TClienteSolicitudes_IdConfiguracionClienteTipo"
        FOREIGN KEY ("IdConfiguracionClienteTipo")
        REFERENCES "TConfiguracionClienteTipos" ("IdConfiguracionClienteTipo")
        ON DELETE SET NULL;

-- =====================================================================
-- 5. Seed: los 3 tipos de cliente + traducciones ES/GL
-- =====================================================================
INSERT INTO "TConfiguracionClienteTipos" ("Nombre") VALUES
    ('Funeraria'),
    ('Tanatorio'),
    ('Eclesiástico')
ON CONFLICT ("Nombre") DO NOTHING;

INSERT INTO "TConfiguracionClienteTiposIdiomas" ("IdConfiguracionClienteTipo", "IdSistemaIdioma", "Nombre")
SELECT t."IdConfiguracionClienteTipo", i."IdSistemaIdioma", v.nombre_traducido
FROM (VALUES
    ('Funeraria', 'ES', 'Funeraria'),
    ('Funeraria', 'GL', 'Funeraria'),
    ('Tanatorio', 'ES', 'Tanatorio'),
    ('Tanatorio', 'GL', 'Tanatorio'),
    ('Eclesiástico', 'ES', 'Eclesiástico'),
    ('Eclesiástico', 'GL', 'Eclesiástico')
) AS v(nombre_base, codigo_idioma, nombre_traducido)
JOIN "TConfiguracionClienteTipos" t ON t."Nombre" = v.nombre_base
JOIN "TSistemaIdiomas" i ON i."Codigo" = v.codigo_idioma
ON CONFLICT ("IdConfiguracionClienteTipo", "IdSistemaIdioma") DO NOTHING;
