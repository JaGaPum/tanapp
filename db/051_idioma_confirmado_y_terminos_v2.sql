-- =====================================================================
-- 051 - Confirmación explícita de idioma + Términos de uso para todos los usuarios
-- =====================================================================
-- Dos cambios relacionados con el alta/aceptación de condiciones:
--
-- 1. Hasta ahora "IdSistemaIdiomaPreferido" se rellenaba solo (gallego por defecto, 047) sin que
--    el usuario lo eligiera nunca explícitamente. Se añade "IdiomaConfirmado" para saber si ya
--    ha pasado por la nueva pantalla "Elige tu idioma" (bloqueo del router justo después de
--    aceptar términos, igual que "elegir sede"): al ir todos a false por defecto, tanto las
--    cuentas nuevas como las ya existentes pasarán por ahí una vez.
--
-- 2. Hasta ahora solo CLIENTE necesitaba aceptar "TERMINOS_USO" (026); un USUARIO_ORDINARIO solo
--    aceptaba "PRIVACIDAD". Como cualquier usuario puede dejar condolencias (y estas pueden ser
--    moderadas por el cliente dueño de la esquela, 050), hace falta que también acepte unas
--    normas de uso. Se reescribe "TERMINOS_USO" (nueva versión activa) para cubrir a los dos
--    perfiles en un único documento, y el filtro de terminos_repository.dart pasa a exigirlo
--    a todo el mundo salvo ADMIN. Al desactivar la v1 y activar la v2, todo el que ya hubiese
--    aceptado la v1 (clientes) tiene que volver a aceptar, esta vez la v2.
-- Requiere que 050 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "IdiomaConfirmado" boolean NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------
-- Términos de uso v2: desactiva la v1 y da de alta la v2 como activa.
-- ---------------------------------------------------------------------
UPDATE "TSistemaTerminos" SET "Activo" = false
WHERE "Tipo" = 'TERMINOS_USO' AND "Version" = 1;

INSERT INTO "TSistemaTerminos" ("Tipo", "Version")
SELECT 'TERMINOS_USO', 2
WHERE NOT EXISTS (SELECT 1 FROM "TSistemaTerminos" WHERE "Tipo" = 'TERMINOS_USO' AND "Version" = 2);

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Términos de uso',
'Estos Términos de uso regulan el uso de TanApp tanto por parte de clientes (funerarias, '
'tanatorios y parroquias) que publican esquelas y avisos de defunción, como por parte de '
'cualquier persona que consulte la app, siga publicaciones o deje condolencias.

PARA CLIENTES (funerarias, tanatorios y parroquias)

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
'terceros y ante la normativa aplicable.

PARA CUALQUIER PERSONA QUE USE LA APP

5. Condolencias. Al dejar un mensaje de condolencia te comprometes a que su contenido sea '
'respetuoso: no está permitido incluir insultos, lenguaje ofensivo, difamatorio o ajeno al '
'propósito de dar el pésame. El cliente que ha publicado la esquela puede moderar las '
'condolencias que recibe en ella -eliminarlas o editar su texto- si considera que no cumplen '
'esta norma, y TanApp también podrá hacerlo. Si tu condolencia es eliminada o editada por '
'este motivo, se te avisará dentro de la app.

6. Uso correcto de la aplicación. El usuario se compromete a hacer un uso correcto de la '
'app y de la información en ella disponible, y a no emplearla con fines distintos a los '
'previstos (consultar y difundir esquelas y avisos de defunción, seguir clientes y zonas, y '
'dejar condolencias).'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'TERMINOS_USO' AND t."Version" = 2 AND i."Codigo" = 'ES'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TSistemaTerminosIdiomas" ("IdSistemaTermino", "IdSistemaIdioma", "Titulo", "Cuerpo")
SELECT t."IdSistemaTermino", i."IdSistemaIdioma", 'Condicións de uso',
'Estas Condicións de uso regulan o uso de TanApp tanto por parte de clientes (funerarias, '
'tanatorios e parroquias) que publican esquelas e avisos de defunción, como por parte de '
'calquera persoa que consulte a app, siga publicacións ou deixe condolencias.

PARA CLIENTES (funerarias, tanatorios e parroquias)

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
'terceiros e ante a normativa aplicable.

PARA CALQUERA PERSOA QUE USE A APP

5. Condolencias. Ao deixar unha mensaxe de condolencia comprométeste a que o seu contido '
'sexa respectuoso: non está permitido incluír insultos, linguaxe ofensiva, difamatoria ou '
'allea ao propósito de dar o pésame. O cliente que publicou a esquela pode moderar as '
'condolencias que recibe nela -eliminalas ou editar o seu texto- se considera que non '
'cumpren esta norma, e TanApp tamén poderá facelo. Se a túa condolencia é eliminada ou '
'editada por este motivo, avisaráseche dentro da app.

6. Uso correcto da aplicación. O usuario comprométese a facer un uso correcto da app e da '
'información nela dispoñible, e a non empregala con fins distintos aos previstos (consultar '
'e difundir esquelas e avisos de defunción, seguir clientes e zonas, e deixar condolencias).'
FROM "TSistemaTerminos" t, "TSistemaIdiomas" i
WHERE t."Tipo" = 'TERMINOS_USO' AND t."Version" = 2 AND i."Codigo" = 'GL'
ON CONFLICT ("IdSistemaTermino", "IdSistemaIdioma") DO NOTHING;
