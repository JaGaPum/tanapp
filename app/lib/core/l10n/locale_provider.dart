import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/sistema_usuarios/data/catalogos_repository.dart';

/// Idioma activo de la app: el guardado como preferencia en el perfil del usuario
/// (Configuración > Mi cuenta), o español si aún no hay usuario / no lo ha elegido.
final appLocaleProvider = Provider.autoDispose<Locale>((ref) {
  final idPreferido = ref.watch(currentUserProfileProvider).value?.idSistemaIdiomaPreferido;
  if (idPreferido == null) return const Locale('es');

  final idiomas = ref.watch(idiomasCatalogoProvider).value ?? const [];
  final codigo = idiomas.where((i) => i.idSistemaIdioma == idPreferido).firstOrNull?.codigo;
  return switch (codigo) {
    'GL' => const Locale('gl'),
    _ => const Locale('es'),
  };
});
