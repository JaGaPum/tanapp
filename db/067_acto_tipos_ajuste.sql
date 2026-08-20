-- =====================================================================
-- 067 - Ajusta el catálogo de tipos de acto (064) a los 4 que se van a usar de verdad
-- =====================================================================
-- Renombra dos de los tipos sembrados en 064 (más cortos, tal y como se van a mostrar en el
-- desplegable y en el chip de la tarjeta) y quita "Misa de mes" (no hace falta: entre "cabo de
-- ano", "aniversario" y "a intención" ya queda cubierto). Los admite el ADMIN, que puede seguir
-- añadiendo más tipos desde Configuración cuando haga falta.
-- Requiere que 064 ya esté aplicado.

UPDATE "TConfiguracionActoTipos" SET "Nombre" = 'Misa a intención'
    WHERE "Nombre" = 'Misa a intención de alguén';

UPDATE "TConfiguracionActoTipos" SET "Nombre" = 'Acto Civil'
    WHERE "Nombre" = 'Acto civil de recordo';

-- ON DELETE SET NULL en "TClientePublicaciones"/"TClientePublicacionesProgramadas" (064): si
-- alguna publicación ya usaba este tipo, se queda sin catalogar en vez de fallar el borrado.
DELETE FROM "TConfiguracionActoTipos" WHERE "Nombre" = 'Misa de mes';
