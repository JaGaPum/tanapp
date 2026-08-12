import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/sistema_usuarios/data/catalogos_repository.dart';

/// Idioma guardado como preferencia en el perfil del usuario (Configuración > Mi cuenta), o
/// null si todavía no hay sesión o el usuario no ha elegido ninguno.
final _localePreferidaProvider = Provider.autoDispose<Locale?>((ref) {
  final idPreferido = ref
      .watch(currentUserProfileProvider)
      .value
      ?.idSistemaIdiomaPreferido;
  if (idPreferido == null) return null;

  final idiomas = ref.watch(idiomasCatalogoProvider).value ?? const [];
  final codigo = idiomas
      .where((i) => i.idSistemaIdioma == idPreferido)
      .firstOrNull
      ?.codigo;
  return switch (codigo) {
    'GL' => const Locale('gl'),
    'ES' => const Locale('es'),
    _ => null,
  };
});

/// Idioma activo de la app para todo lo que no sea el propio "locale" de MaterialApp (qué
/// idioma de contenido pedir, voz de la lectura en alto...): la preferencia del usuario, o
/// español si aún no hay sesión o preferencia.
final appLocaleProvider = Provider.autoDispose<Locale>((ref) {
  return ref.watch(_localePreferidaProvider) ?? const Locale('es');
});

/// Idioma que fuerza la UI de MaterialApp (ver "locale" en app.dart): la preferencia del
/// usuario si la hay, o "null" para dejar que Flutter la resuelva por el idioma del sistema
/// (con gallego como última opción si el sistema no está en español ni en gallego — ver
/// "localeResolutionCallback" en app.dart). Antes de iniciar sesión no hay preferencia todavía,
/// que es justo donde se nota la diferencia con [appLocaleProvider].
final materialAppLocaleProvider = Provider.autoDispose<Locale?>((ref) {
  return ref.watch(_localePreferidaProvider);
});
