import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Pantalla de arranque: mismo fondo e icono que la splash nativa (ver
/// android/app/src/main/res/drawable/launch_background.xml), para que no haya salto visual al
/// pasar de una a otra. Se queda al menos [_duracionMinima], y luego pasa a "/login" — desde ahí
/// el "redirect" normal del router decide adónde ir según haya sesión o no.
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
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Image(
          image: AssetImage('assets/icon/app_icon.png'),
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
