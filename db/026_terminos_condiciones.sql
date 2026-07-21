-- =====================================================================
-- 026 - Aceptación obligatoria de condiciones de uso y privacidad
-- =====================================================================
-- Documentos legales versionados (Términos de uso / Política de privacidad), con contenido
-- por idioma (mismo patrón bilingüe que TConfiguracionComunicaciones/...Idiomas en 006), y
-- registro de qué usuario ha aceptado qué versión. El bloqueo real (no dejar usar la app sin
-- aceptar) lo implementa el router de Flutter, no esta migración.
-- Requiere que 025 ya esté aplicado.

-- =====================================================================
-- 1. Documentos: tipo + versión, como mucho un activo por tipo a la vez
-- =====================================================================
CREATE TABLE "TSistemaTerminos" (
    "IdSistemaTermino" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "Tipo" varchar(20) NOT NULL CHECK ("Tipo" IN ('TERMINOS_USO', 'PRIVACIDAD')),
    "Version" integer NOT NULL,
    "Activo" boolean NOT NULL DEFAULT true,
    "FechaAlta" timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "UX_TSistemaTerminos_Tipo_Version" ON "TSistemaTerminos" ("Tipo", "Version");
CREATE UNIQUE INDEX "UX_TSistemaTerminos_Tipo_Activo" ON "TSistemaTerminos" ("Tipo") WHERE "Activo";

-- =====================================================================
-- 2. Contenido por idioma
-- =====================================================================
CREATE TABLE "TSistemaTerminosIdiomas" (
    "IdSistemaTerminoIdioma" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaTermino" uuid NOT NULL,
    "IdSistemaIdioma" uuid NOT NULL,
    "Titulo" varchar(200) NOT NULL,
    "Cuerpo" text NOT NULL
);

ALTER TABLE "TSistemaTerminosIdiomas"
    ADD CONSTRAINT "FK_TSistemaTerminosIdiomas_IdSistemaTermino"
        FOREIGN KEY ("IdSistemaTermino")
        REFERENCES "TSistemaTerminos" ("IdSistemaTermino")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TSistemaTerminosIdiomas_IdSistemaIdioma"
        FOREIGN KEY ("IdSistemaIdioma")
        REFERENCES "TSistemaIdiomas" ("IdSistemaIdioma")
        ON DELETE RESTRICT;

CREATE UNIQUE INDEX "UX_TSistemaTerminosIdiomas_Termino_Idioma"
    ON "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma");

-- =====================================================================
-- 3. Aceptaciones de usuario (inmutable: sin UPDATE/DELETE)
-- =====================================================================
CREATE TABLE "TSistemaTerminosAceptaciones" (
    "IdSistemaTerminoAceptacion" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "IdSistemaUsuario" uuid NOT NULL,
    "IdSistemaTermino" uuid NOT NULL,
    "FechaAceptacion" timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE "TSistemaTerminosAceptaciones"
    ADD CONSTRAINT "FK_TSistemaTerminosAceptaciones_IdSistemaUsuario"
        FOREIGN KEY ("IdSistemaUsuario")
        REFERENCES "TSistemaUsuarios" ("IdSistemaUsuario")
        ON DELETE CASCADE,
    ADD CONSTRAINT "FK_TSistemaTerminosAceptaciones_IdSistemaTermino"
        FOREIGN KEY ("IdSistemaTermino")
        REFERENCES "TSistemaTerminos" ("IdSistemaTermino")
        ON DELETE RESTRICT;

CREATE UNIQUE INDEX "UX_TSistemaTerminosAceptaciones_Usuario_Termino"
    ON "TSistemaTerminosAceptaciones" ("IdSistemaUsuario", "IdSistemaTermino");
CREATE INDEX "IX_TSistemaTerminosAceptaciones_IdSistemaUsuario"
    ON "TSistemaTerminosAceptaciones" ("IdSistemaUsuario");

-- =====================================================================
-- 4. RLS
-- =====================================================================
ALTER TABLE "TSistemaTerminos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TSistemaTerminosIdiomas" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TSistemaTerminosAceptaciones" ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado necesita poder leer los documentos para poder aceptarlos.
CREATE POLICY "select_authenticated_TSistemaTerminos" ON "TSistemaTerminos"
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "select_authenticated_TSistemaTerminosIdiomas" ON "TSistemaTerminosIdiomas"
    FOR SELECT TO authenticated
    USING (true);

-- Solo ADMIN da de alta/edita documentos (sin pantalla propia en la app todavía; se
-- gestionan por SQL, igual que TConfiguracionComunicaciones en 006).
CREATE POLICY "mutacion_admin_TSistemaTerminos" ON "TSistemaTerminos"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

CREATE POLICY "mutacion_admin_TSistemaTerminosIdiomas" ON "TSistemaTerminosIdiomas"
    FOR ALL TO authenticated
    USING ("FSistemaUsuarioTieneRol"('ADMIN'))
    WITH CHECK ("FSistemaUsuarioTieneRol"('ADMIN'));

-- Cada usuario ve/registra solo sus propias aceptaciones (mismo patrón que
-- TSistemaDispositivosPush en 024).
CREATE POLICY "select_propio_TSistemaTerminosAceptaciones" ON "TSistemaTerminosAceptaciones"
    FOR SELECT TO authenticated
    USING (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

CREATE POLICY "insert_propio_TSistemaTerminosAceptaciones" ON "TSistemaTerminosAceptaciones"
    FOR INSERT TO authenticated
    WITH CHECK (
        "IdSistemaUsuario" IN (
            SELECT "IdSistemaUsuario" FROM "TSistemaUsuarios" WHERE "IdAuthSupabase" = auth.uid()
        )
    );

-- =====================================================================
-- 5. Seed: versión 1 de cada documento, en español y gallego
-- =====================================================================
INSERT INTO "TSistemaTerminos" ("Tipo", "Version")
SELECT 'TERMINOS_USO', 1
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaTerminos" WHERE "Tipo" = 'TERMINOS_USO' AND "Version" = 1);

INSERT INTO "TSistemaTerminos" ("Tipo", "Version")
SELECT 'PRIVACIDAD', 1
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaTerminos" WHERE "Tipo" = 'PRIVACIDAD' AND "Version" = 1);

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Términos de uso',
'Estos Términos de uso regulan la publicación de esquelas y avisos de defunción en TanApp por '
'parte de clientes (funerarias, tanatorios y parroquias).

1. Veracidad de los datos. El cliente es el único responsable de que los datos que publica '
'(nombre del fallecido, fechas, lugares, y cualquier otro dato incluido en la esquela) sean '
'veraces, estén actualizados y cuente con la autorización necesaria para su publicación.

2. Protección de datos de terceros. No se deben incluir en las publicaciones datos '
'personales de familiares u otras personas (nombres, teléfonos, direcciones) más allá del '
'nombre del fallecido y la información estrictamente necesaria para el público (iglesia, '
'lugar, tanatorio, sala, fecha y hora del funeral).

3. Retirada de contenido. TanApp podrá retirar cualquier publicación que incumpla estos '
'términos, sin perjuicio de otras acciones que puedan corresponder.

4. Responsabilidad. TanApp actúa como plataforma de difusión y no se hace responsable del '
'contenido publicado por sus clientes, siendo estos los únicos responsables frente a '
'terceros y ante la normativa aplicable.'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'TERMINOS_USO' AND t."Version" = 1 AND i."Codigo" = 'ES'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Condicións de uso',
'Estas Condicións de uso regulan a publicación de esquelas e avisos de defunción en TanApp '
'por parte de clientes (funerarias, tanatorios e parroquias).

1. Veracidade dos datos. O cliente é o único responsable de que os datos que publica (nome '
'do falecido, datas, lugares, e calquera outro dato incluído na esquela) sexan veraces, '
'estean actualizados e conte coa autorización necesaria para a súa publicación.

2. Protección de datos de terceiros. Non se deben incluír nas publicacións datos persoais '
'de familiares ou outras persoas (nomes, teléfonos, enderezos) máis alá do nome do falecido '
'e a información estritamente necesaria para o público (igrexa, lugar, tanatorio, sala, '
'data e hora do funeral).

3. Retirada de contido. TanApp poderá retirar calquera publicación que incumpra estas '
'condicións, sen prexuízo doutras accións que poidan corresponder.

4. Responsabilidade. TanApp actúa como plataforma de difusión e non se fai responsable do '
'contido publicado polos seus clientes, sendo estes os únicos responsables fronte a '
'terceiros e ante a normativa aplicable.'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'TERMINOS_USO' AND t."Version" = 1 AND i."Codigo" = 'GL'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Política de privacidad',
'De acuerdo con el Reglamento General de Protección de Datos (RGPD), le informamos de lo '
'siguiente:

1. Responsable del tratamiento. TanApp es responsable del tratamiento de los datos '
'personales que usted nos facilita al registrarse y usar la aplicación.

2. Datos que tratamos. Datos de su perfil (nombre, email, teléfono, concello, provincia), '
'las funerarias/tanatorios que sigue, el idioma preferido, y el identificador de su '
'dispositivo móvil si activa las notificaciones push.

3. Finalidad. Prestarle el servicio de la aplicación (consultar esquelas, seguir clientes, '
'publicar si es cliente) y avisarle de nuevas publicaciones de los clientes que sigue.

4. Base legal. La ejecución del servicio que usted solicita al registrarse, y su '
'consentimiento para el envío de notificaciones push.

5. Conservación. Sus datos se conservan mientras su cuenta permanezca activa.

6. Destinatarios. Utilizamos Supabase y Firebase (Google) como encargados del tratamiento '
'para alojar los datos y enviar notificaciones push, respectivamente. No cedemos ni '
'vendemos sus datos a terceros con fines comerciales.

7. Datos de personas fallecidas y de las esquelas. Los datos de la persona fallecida que '
'aparecen en una esquela los publica el cliente (funeraria/tanatorio/parroquia) bajo su '
'propia responsabilidad, no en base al consentimiento del usuario que consulta la '
'publicación.

8. Sus derechos. Puede ejercer sus derechos de acceso, rectificación, supresión, '
'oposición, limitación y portabilidad escribiendo a la dirección de contacto indicada en '
'la aplicación.'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'PRIVACIDAD' AND t."Version" = 1 AND i."Codigo" = 'ES'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Política de privacidade',
'De acordo co Regulamento Xeral de Protección de Datos (RGPD), informámoslle do seguinte:

1. Responsable do tratamento. TanApp é responsable do tratamento dos datos persoais que '
'vostede nos facilita ao rexistrarse e usar a aplicación.

2. Datos que tratamos. Datos do seu perfil (nome, email, teléfono, concello, provincia), as '
'funerarias/tanatorios que segue, o idioma preferido, e o identificador do seu dispositivo '
'móbil se activa as notificacións push.

3. Finalidade. Prestarlle o servizo da aplicación (consultar esquelas, seguir clientes, '
'publicar se é cliente) e avisarlle de novas publicacións dos clientes que segue.

4. Base legal. A execución do servizo que vostede solicita ao rexistrarse, e o seu '
'consentimento para o envío de notificacións push.

5. Conservación. Os seus datos consérvanse mentres a súa conta permaneza activa.

6. Destinatarios. Utilizamos Supabase e Firebase (Google) como encargados do tratamento '
'para aloxar os datos e enviar notificacións push, respectivamente. Non cedemos nin '
'vendemos os seus datos a terceiros con fins comerciais.

7. Datos de persoas falecidas e das esquelas. Os datos da persoa falecida que aparecen '
'nunha esquela publícaos o cliente (funeraria/tanatorio/parroquia) baixo a súa propia '
'responsabilidade, non en base ao consentimento do usuario que consulta a publicación.

8. Os seus dereitos. Pode exercer os seus dereitos de acceso, rectificación, supresión, '
'oposición, limitación e portabilidade escribindo á dirección de contacto indicada na '
'aplicación.'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'PRIVACIDAD' AND t."Version" = 1 AND i."Codigo" = 'GL'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;
