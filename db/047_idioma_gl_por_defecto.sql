-- =====================================================================
-- 047 - Idioma preferido por defecto: gallego para cualquier alta nueva
-- =====================================================================
-- "FSistemaHandleNewAuthUser" (002/003/011/034) nunca rellenaba "IdSistemaIdiomaPreferido" al
-- crear el perfil, así que se quedaba NULL para cualquier alta (usuario ordinario, Google OAuth,
-- o cliente dado de alta por un admin vía la Edge Function "aprobar-solicitud-cliente" — todas
-- pasan por este mismo trigger, al insertar en auth.users). Con NULL, tanto la app
-- (appLocaleProvider) como los avisos push (enviar-push-aviso) caían al español por defecto.
-- Se cambia el valor por defecto a gallego (Codigo = 'GL'), sin tocar nada más del trigger.

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
            NEW.raw_user_meta_data ->> 'name',
            NEW.raw_user_meta_data ->> 'full_name',
            NEW.email
        ),
        COALESCE(NEW.raw_user_meta_data ->> 'apellido1', NEW.raw_user_meta_data ->> 'family_name'),
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
