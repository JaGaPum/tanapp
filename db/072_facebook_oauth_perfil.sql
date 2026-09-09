-- =====================================================================
-- 072 - El alta automática de perfil también reconoce los metadatos de Facebook OAuth
-- =====================================================================
-- Mismo motivo que 034 con Google: un alta por Facebook (signInWithOAuth, solo desde la
-- pantalla de usuario ordinario, nunca la de cliente — ver login_screen.dart) manda sus propios
-- nombres de campo en "raw_user_meta_data" ("first_name"/"last_name" además del "name"/
-- "full_name" genérico que ya cubría Google). Sin este cambio no fallaba nada -son todos
-- NULL-able-, pero el apellido se quedaba vacío para un alta de Facebook aunque Facebook sí lo
-- mande.
--
-- Cambia el cuerpo, no la firma: un CREATE OR REPLACE simple vale (mismo motivo que en 047/064).
-- Se parte de la versión de 047 (la última que tocó el cuerpo entero de este trigger).
-- Requiere que 047 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaHandleNewAuthUser"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    nuevo_id uuid;
    id_rol_ordinario uuid;
    id_idioma_gl uuid;
BEGIN
    SELECT "IdSistemaIdioma" INTO id_idioma_gl
    FROM "TSistemaIdiomas"
    WHERE "Codigo" = 'GL';

    INSERT INTO "TSistemaUsuarios"
        ("IdAuthSupabase", "Email", "Nombre", "Apellido1", "Apellido2", "Telefono", "Concello",
         "Provincia", "Direccion", "IdSistemaIdiomaPreferido")
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data ->> 'nombre',
            NEW.raw_user_meta_data ->> 'given_name',
            NEW.raw_user_meta_data ->> 'first_name',
            NEW.raw_user_meta_data ->> 'name',
            NEW.raw_user_meta_data ->> 'full_name',
            NEW.email
        ),
        COALESCE(
            NEW.raw_user_meta_data ->> 'apellido1',
            NEW.raw_user_meta_data ->> 'family_name',
            NEW.raw_user_meta_data ->> 'last_name'
        ),
        NEW.raw_user_meta_data ->> 'apellido2',
        NEW.raw_user_meta_data ->> 'telefono',
        NEW.raw_user_meta_data ->> 'concello',
        NEW.raw_user_meta_data ->> 'provincia',
        NEW.raw_user_meta_data ->> 'direccion',
        id_idioma_gl
    )
    RETURNING "IdSistemaUsuario" INTO nuevo_id;

    SELECT "IdSistemaRol" INTO id_rol_ordinario
    FROM "TSistemaRoles"
    WHERE "Codigo" = 'USUARIO_ORDINARIO';

    IF id_rol_ordinario IS NOT NULL THEN
        INSERT INTO "TSistemaUsuariosRoles" ("IdSistemaUsuario", "IdSistemaRol")
        VALUES (nuevo_id, id_rol_ordinario);
    END IF;

    RETURN NEW;
END;
$$;
