-- =====================================================================
-- 068 - El ADMIN puede obligar a un usuario a cambiar su contraseña
-- =====================================================================
-- Nueva columna "DebeCambiarContrasena": la marca el ADMIN desde la ficha de usuario
-- ("update_propio_o_admin_TSistemaUsuarios" de 002 ya le permite escribir en cualquier fila,
-- sin restricción de columnas, ver nota de 058). El router (`app_router.dart`) la comprueba una
-- vez por carga de la app, igual que términos/idioma/sede, y si está activa reutiliza el mismo
-- mecanismo que ya fuerza "/reset-password" durante una recuperación normal (el flag
-- "enRecuperacionContrasena" del guard, no esta columna directamente, para no tener que volver a
-- consultar la base de datos en cada "redirect"). El propio usuario la desactiva sola (misma
-- policy, ahora sobre su propia fila) en cuanto guarda la contraseña nueva.
-- Requiere que 002 ya esté aplicado.

ALTER TABLE "TSistemaUsuarios"
    ADD COLUMN "DebeCambiarContrasena" boolean NOT NULL DEFAULT false;
