-- =====================================================================
-- 011 - Dirección completa del cliente, para poder abrir "Cómo llegar" en
--        Google Maps desde la solicitud y desde la ficha de usuario
-- =====================================================================
-- Requiere que 010 ya esté aplicado.

-- =====================================================================
-- 1. Columna nueva en ambas tablas (nullable a nivel de BD, obligatoria a
--    nivel de formulario Flutter — mismo criterio que Localidad/Provincia)
-- =====================================================================
ALTER TABLE "TClienteSolicitudes"
    ADD COLUMN "Direccion" varchar(255) NULL;

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "Direccion" varchar(255) NULL;

-- =====================================================================
-- 2. FSistemaHandleNewAuthUser: añade "Direccion" a los campos que ya
--    propaga desde raw_user_meta_data (apellido1/apellido2/telefono/
--    concello/provincia, ver 003_sesiones_avatares_y_datos_personales.sql)
-- =====================================================================
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
        COALESCE(NEW.raw_user_meta_data ->> 'nombre', NEW.email),
        NEW.raw_user_meta_data ->> 'apellido1',
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
