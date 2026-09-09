-- =====================================================================
-- 074 - Configuración global > interruptor del login con Apple
-- =====================================================================
-- Mismo patrón que "GoogleLoginActivo"/"FacebookLoginActivo" (073): el admin puede mostrar u
-- ocultar el botón "Continuar con Apple" sin tocar código ni desplegar nada -por ejemplo,
-- mientras no se ha dado de alta la cuenta de Apple Developer Program o configurado el proveedor
-- en Supabase-. Por eso empieza en false, igual que Facebook empezó desactivado.
--
-- La policy de SELECT para "anon" ya existe desde 073 (cubre toda la tabla, no columna a
-- columna), así que no hace falta crear una nueva aquí.
--
-- Requiere que 073 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD COLUMN "AppleLoginActivo" boolean NOT NULL DEFAULT false;
