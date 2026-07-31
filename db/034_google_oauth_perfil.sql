-- =====================================================================
-- 034 - El alta automática de perfil también reconoce los metadatos de Google OAuth
-- =====================================================================
-- "FSistemaHandleNewAuthUser" (002/003/011) solo leía "nombre"/"apellido1"/... , los nombres de
-- campo que manda el formulario de registro por email como metadata custom del signup. Un alta
-- por Google (signInWithOAuth) no manda esos campos: Supabase rellena "raw_user_meta_data" con
-- lo que devuelve Google ("full_name", "given_name", "family_name", "name", ...). Sin este
-- cambio, el trigger no fallaba (todo es NULL-able) pero dejaba "Nombre" = email y el resto de
-- campos personales vacíos. Se añade el fallback a los campos de Google, dando prioridad
-- siempre a los del formulario propio si vinieran ambos.
-- Requiere que 033 ya esté aplicado.

CREATE OR REPLACE FUNCTION "FSistemaHandleNewAuthUser"()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    nuevo_id uuid;
    id_rol_ordinario uuid;
BEGIN
    INSERT INTO "TSistemaUsuarios"
        ("IdAuthSupabase", "Email", "Nombre", "Apellido1", "Apellido2", "Telefono", "Concello", "Provincia", "Direccion")
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
        NEW.raw_user_meta_data ->> 'direccion'
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
