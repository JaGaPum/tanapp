-- =====================================================================
-- 006 - Configuración > Comunicaciones (textos de email/mensaje/notificación
--        multi-idioma) y rol CLIENTE para usuarios creados al aprobar una
--        solicitud de alta
-- =====================================================================
-- Requiere que 005 ya esté aplicado.

-- =====================================================================
-- 1. Idiomas base: Español y Galego (idempotente, sin asumir constraint único)
-- =====================================================================
INSERT INTO "TSistemaIdiomas" ("Codigo", "Nombre")
SELECT 'ES', 'Español'
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaIdiomas" WHERE "Codigo" = 'ES');

INSERT INTO "TSistemaIdiomas" ("Codigo", "Nombre")
SELECT 'GL', 'Galego'
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaIdiomas" WHERE "Codigo" = 'GL');

-- =====================================================================
-- 2. Rol CLIENTE: se asigna a los usuarios creados al aprobar una solicitud
--    de alta de cliente (funeraria/tanatorio/parroquia), además de
--    USUARIO_ORDINARIO que ya asigna el trigger de alta por defecto.
-- =====================================================================
INSERT INTO "TSistemaRoles" ("Codigo", "Nombre")
SELECT 'CLIENTE', 'Cliente'
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaRoles" WHERE "Codigo" = 'CLIENTE');

-- =====================================================================
-- 3. Tablas: TConfiguracionComunicaciones + traducciones por idioma
-- =====================================================================
CREATE TABLE "TConfiguracionComunicaciones" (
    "IdConfiguracionComunicacion" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "TipoComunicacion" varchar(20) NOT NULL
        CHECK ("TipoComunicacion" IN ('EMAIL', 'MENSAJE', 'NOTIFICACION')),
    "CodComunicacion" varchar(50) NOT NULL,
    "NombreComunicacion" varchar(200) NOT NULL,
    "Remitente" varchar(200) NULL,
    "Activo" boolean NOT NULL DEFAULT true,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TConfiguracionComunicaciones_CodComunicacion"
    ON "TConfiguracionComunicaciones" ("CodComunicacion");

CREATE TABLE "TConfiguracionComunicacionesIdiomas" (
    "IdConfiguracionComunicacionIdioma" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdConfiguracionComunicacion" uuid NOT NULL,
    "IdSistemaIdioma" uuid NOT NULL,
    "Asunto" varchar(255) NULL,
    "Cuerpo" text NOT NULL,
    "FechaAlta" timestamptz NOT NULL DEFAULT now(),
    "FechaModificacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TConfiguracionComunicacionesIdiomas"
    ADD CONSTRAINT "FK_TConfiguracionComunicacionesIdiomas_IdConfiguracionComunicacion"
        FOREIGN KEY ("IdConfiguracionComunicacion")
        REFERENCES "TConfiguracionComunicaciones" ("IdConfiguracionComunicacion")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TConfiguracionComunicacionesIdiomas_IdSistemaIdioma"
        FOREIGN KEY ("IdSistemaIdioma")
        REFERENCES "TSistemaIdiomas" ("IdSistemaIdioma")
        ON DELETE RESTRICT;

CREATE UNIQUE INDEX "UX_TConfiguracionComunicacionesIdiomas_Comunicacion_Idioma"
    ON "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma");

ALTER TABLE "TConfiguracionComunicaciones" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TConfiguracionComunicacionesIdiomas" ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionComunicaciones"
    BEFORE UPDATE ON "TConfiguracionComunicaciones"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

CREATE TRIGGER "trigger_FechaModificacion_TConfiguracionComunicacionesIdiomas"
    BEFORE UPDATE ON "TConfiguracionComunicacionesIdiomas"
    FOR EACH ROW EXECUTE FUNCTION "FSistemaSetFechaModificacion"();

-- Solo ADMIN gestiona/lee las comunicaciones (configuración interna, no la
-- consume ningún formulario público; el futuro envío real lo hará una Edge
-- Function con service_role, que no pasa por RLS).
CREATE POLICY "mutacion_admin_TConfiguracionComunicaciones" ON "TConfiguracionComunicaciones"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "mutacion_admin_TConfiguracionComunicacionesIdiomas" ON "TConfiguracionComunicacionesIdiomas"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- =====================================================================
-- 4. Seed: comunicaciones de ejemplo para aprobación/rechazo de solicitudes
-- =====================================================================
INSERT INTO "TConfiguracionComunicaciones"
    ("TipoComunicacion", "CodComunicacion", "NombreComunicacion", "Remitente")
SELECT 'EMAIL', 'SOLICITUD_APROBADA', 'Email de aprobación de solicitud de cliente', 'tanapp@noreply.gal'
WHERE NOT EXISTS (
    SELECT 1 FROM "TConfiguracionComunicaciones" WHERE "CodComunicacion" = 'SOLICITUD_APROBADA'
);

INSERT INTO "TConfiguracionComunicaciones"
    ("TipoComunicacion", "CodComunicacion", "NombreComunicacion", "Remitente")
SELECT 'EMAIL', 'SOLICITUD_RECHAZADA', 'Email de rechazo de solicitud de cliente', 'tanapp@noreply.gal'
WHERE NOT EXISTS (
    SELECT 1 FROM "TConfiguracionComunicaciones" WHERE "CodComunicacion" = 'SOLICITUD_RECHAZADA'
);

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Aprobación de tu solicitud',
    'Estimado/a Sr./Sra., le comunicamos que hemos aprobado su solicitud de alta en TanApp. '
    'En breve podrá acceder utilizando la opción "¿Olvidaste tu contraseña?" en la pantalla de inicio de sesión.'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'SOLICITUD_APROBADA' AND i."Codigo" = 'ES'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Aprobación da túa solicitude',
    'Estimado/a Sr./Sra., comunicámoslle que aprobamos a súa solicitude de alta en TanApp. '
    'En breve poderá acceder empregando a opción "Non recordo o contrasinal" na pantalla de inicio de sesión.'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'SOLICITUD_APROBADA' AND i."Codigo" = 'GL'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Sobre tu solicitud',
    'Estimado/a Sr./Sra., le comunicamos que no hemos podido aprobar su solicitud de alta en TanApp en esta ocasión.'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'SOLICITUD_RECHAZADA' AND i."Codigo" = 'ES'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Sobre a túa solicitude',
    'Estimado/a Sr./Sra., comunicámoslle que non puidemos aprobar a súa solicitude de alta en TanApp nesta ocasión.'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'SOLICITUD_RECHAZADA' AND i."Codigo" = 'GL'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;
