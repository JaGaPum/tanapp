-- =====================================================================
-- 061 - Comunicación "Baja confirmada": email al usuario que se da de baja
-- =====================================================================
-- Plantilla bilingüe para el email que recibe un CLIENTE/USUARIO_ORDINARIO en cuanto efectúa su
-- baja en autoservicio (ver AccountScreen y TSistemaBajas, 058): lo envía la Edge Function
-- "enviar-push-baja" (que, pese al nombre heredado, ahora también manda este email vía Resend)
-- al mismo tiempo que avisa por push al admin. "{nombre}" se sustituye en el envío.
--
-- Requiere que 006 (TConfiguracionComunicaciones) y 058 ya estén aplicados.

INSERT INTO "TConfiguracionComunicaciones"
    ("TipoComunicacion", "CodComunicacion", "NombreComunicacion", "Remitente")
SELECT 'EMAIL', 'BAJA_CONFIRMADA', 'Email de confirmación de baja de cuenta', 'no-reply@tanapp.es'
WHERE NOT EXISTS (
    SELECT 1 FROM "TConfiguracionComunicaciones" WHERE "CodComunicacion" = 'BAJA_CONFIRMADA'
);

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Te has dado de baja de TanApp',
    'Hola {nombre},

Te confirmamos que tu cuenta en TanApp ha sido dada de baja correctamente y ya no está activa.

Queremos darte las gracias por haber formado parte de TanApp durante este tiempo. Si en algún momento cambias de idea, estaremos encantados de tenerte de nuevo: puedes darte de alta otra vez cuando quieras.

Un saludo,
El equipo de TanApp'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'BAJA_CONFIRMADA' AND i."Codigo" = 'ES'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;

INSERT INTO "TConfiguracionComunicacionesIdiomas" ("IdConfiguracionComunicacion", "IdSistemaIdioma", "Asunto", "Cuerpo")
SELECT c."IdConfiguracionComunicacion", i."IdSistemaIdioma", 'Déchaste de baixa de TanApp',
    'Ola {nombre},

Confirmámosche que a túa conta en TanApp foi dada de baixa correctamente e xa non está activa.

Queremos darche as grazas por ter formado parte de TanApp durante este tempo. Se nalgún momento cambias de idea, estaremos encantados de terte de novo: podes darte de alta outra vez cando queiras.

Un saúdo,
O equipo de TanApp'
FROM "TConfiguracionComunicaciones" c, "TSistemaIdiomas" i
WHERE c."CodComunicacion" = 'BAJA_CONFIRMADA' AND i."Codigo" = 'GL'
ON CONFLICT ("IdConfiguracionComunicacion", "IdSistemaIdioma") DO NOTHING;
