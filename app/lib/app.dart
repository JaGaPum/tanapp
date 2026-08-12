import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class TanApp extends ConsumerWidget {
  const TanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(materialAppLocaleProvider);
    return MaterialApp.router(
      title: 'TanApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      // "null" (sin preferencia guardada todavía, p. ej. antes de iniciar sesión) deja que
      // Flutter elija por el idioma del sistema; si ese idioma no es ni español ni gallego, el
      // gallego es la última opción por defecto (no el español), al ser la región de origen de
      // la app.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (systemLocale, supportedLocales) {
        if (systemLocale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == systemLocale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('gl');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
