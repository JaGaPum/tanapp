-- =====================================================================
-- 073 - Configuración global > interruptores del login con Google y con Facebook
-- =====================================================================
-- Mismo patrón que "ImportacionWebIaActiva"/"EscaneoEsquelaIaActiva" (030/041): el admin puede
-- ocultar cualquiera de los dos botones de login social sin tocar código ni desplegar nada -por
-- ejemplo, mientras el login con Facebook está pendiente de que Meta apruebe la app (requiere
-- verificación fiscal/de negocio que todavía no está resuelta)-.
--
-- A diferencia de las dos columnas de 030/041, esta hace falta leerla también DESDE la pantalla
-- de login, es decir, ANTES de que haya sesión iniciada -el visitante todavía es "anon", no
-- "authenticated"-, así que hace falta una policy de SELECT nueva para el rol "anon" (la que ya
-- había en 030 solo cubre "authenticated"); no es información sensible, así que no hay problema
-- en abrirla a cualquiera sin autenticar.
--
-- Requiere que 030 ya esté aplicado.

ALTER TABLE "TConfiguracionGlobal"
    ADD COLUMN "GoogleLoginActivo" boolean NOT NULL DEFAULT true,
    ADD COLUMN "FacebookLoginActivo" boolean NOT NULL DEFAULT false;

CREATE POLICY "select_anon_TConfiguracionGlobal" ON "TConfiguracionGlobal"
    FOR SELECT TO anon
    USING (true);
