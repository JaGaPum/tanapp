-- =====================================================================
-- Utilidad: fija la contraseña de un usuario directamente en Supabase Auth.
--
-- No es una migración (no cambia el esquema): es un script para ejecutar a mano
-- desde el SQL Editor de Supabase, útil mientras no haya SMTP configurado y
-- "¿Olvidaste tu contraseña?" no pueda enviar el correo de recuperación.
--
-- Sustituye EMAIL y NUEVA_CONTRASENA por los valores reales antes de ejecutar,
-- y borra la contraseña de este archivo/del historial de la consola después de usarla.
-- =====================================================================

UPDATE auth.users
SET encrypted_password = crypt('NUEVA_CONTRASENA', gen_salt('bf')),
    updated_at = now()
WHERE email = 'EMAIL@ejemplo.com';

-- Si Postgres da error de función "crypt"/"gen_salt" no encontrada, es que en este
-- proyecto la extensión pgcrypto vive en el esquema "extensions" y no está en el
-- search_path por defecto. En ese caso, usa esta variante en su lugar:
--
-- UPDATE auth.users
-- SET encrypted_password = extensions.crypt('NUEVA_CONTRASENA', extensions.gen_salt('bf')),
--     updated_at = now()
-- WHERE email = 'EMAIL@ejemplo.com';
