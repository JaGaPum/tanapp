import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de arranque: mismo fondo e icono que la splash nativa (ver
/// android/app/src/main/res/drawable/launch_background.xml), para que no haya salto visual al
/// pasar de una a otra. Se queda al menos [_duracionMinima], y luego pasa a "/bienvenida" (si no
/// hay sesión) o directamente a "/home" (si ya la hay) — desde ahí el "redirect" normal del
/// router decide el resto (términos, idioma, sede...).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duracionMinima = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    Future.delayed(_duracionMinima, () {
      if (!mounted) return;
      // Tras un login con Google, Android puede haber matado la app en segundo plano mientras
      // se estaba un rato en el navegador (frecuente en MIUI/Xiaomi) y recrearla desde cero al
      // volver por el enlace de vuelta: sin este chequeo, se pasaba siempre por "/bienvenida"
      // -la pantalla de elegir particular/funeraria- aunque el login ya hubiese terminado y solo
      // fuese a rebotar a "/home", dejándola visible ese rato de más sin motivo.
      final haySesion = Supabase.instance.client.auth.currentSession != null;
      context.go(haySesion ? '/home' : '/bienvenida');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: AssetImage('assets/icon/app_icon.png'),
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.appTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
