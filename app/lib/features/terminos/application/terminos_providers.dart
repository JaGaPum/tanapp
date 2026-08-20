import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../sistema_usuarios/data/usuarios_repository.dart';
import '../data/termino.dart';
import '../data/termino_aceptacion_detalle.dart';
import '../data/termino_documento.dart';
import '../data/terminos_repository.dart';

final terminosPendientesProvider = FutureProvider.autoDispose<List<Termino>>((
  ref,
) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return const [];
  final idiomaCodigo = ref.watch(appLocaleProvider).languageCode == 'gl'
      ? 'GL'
      : 'ES';
  return ref
      .watch(terminosRepositoryProvider)
      .fetchPendientes(perfil.idSistemaUsuario, perfil.roles, idiomaCodigo);
});

final terminosActivosProvider = FutureProvider.autoDispose<List<Termino>>((
  ref,
) async {
  final perfil = await ref.watch(currentUserProfileProvider.future);
  if (perfil == null) return const [];
  final idiomaCodigo = ref.watch(appLocaleProvider).languageCode == 'gl'
      ? 'GL'
      : 'ES';
  return ref
      .watch(terminosRepositoryProvider)
      .fetchActivos(perfil.roles, idiomaCodigo);
});

/// Para la ficha de usuario del ADMIN: si [idSistemaUsuario] tiene documentos activos
/// pendientes de aceptar (vacío = al día). El idioma en el que se piden los documentos no
/// afecta a cuáles están pendientes (eso depende del tipo, no del idioma del contenido), así
/// que aquí basta uno fijo.
final terminosPendientesDeUsuarioProvider = FutureProvider.autoDispose
    .family<List<Termino>, String>((ref, idSistemaUsuario) async {
      final perfil = await ref
          .watch(usuariosRepositoryProvider)
          .fetchPerfilById(idSistemaUsuario);
      return ref
          .watch(terminosRepositoryProvider)
          .fetchPendientes(perfil.idSistemaUsuario, perfil.roles, 'ES');
    });

/// Detalle documento a documento (con fecha de aceptación) para la ficha de usuario del admin.
final terminosDetalleDeUsuarioProvider = FutureProvider.autoDispose
    .family<List<TerminoAceptacionDetalle>, String>((
      ref,
      idSistemaUsuario,
    ) async {
      final perfil = await ref
          .watch(usuariosRepositoryProvider)
          .fetchPerfilById(idSistemaUsuario);
      return ref
          .watch(terminosRepositoryProvider)
          .fetchDetalleAceptaciones(
            perfil.idSistemaUsuario,
            perfil.roles,
            'ES',
          );
    });

/// Para "Configuración > Términos y condiciones" (admin): los documentos activos con su
/// contenido en todos los idiomas, listos para editar.
final terminosDocumentosEditablesProvider =
    FutureProvider.autoDispose<List<TerminoDocumento>>((ref) {
      return ref.watch(terminosRepositoryProvider).fetchDocumentosEditables();
    });
