import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cliente_importacion_web.dart';
import '../data/importacion_web_repository.dart';

final miImportacionWebProvider =
    FutureProvider.autoDispose<ClienteImportacionWeb?>((ref) {
      return ref.watch(importacionWebRepositoryProvider).fetchPropia();
    });

/// Para la ficha de usuario del administrador: configuración de importación web de un
/// cliente cualquiera (por su IdSistemaUsuario).
final importacionWebDeUsuarioProvider = FutureProvider.autoDispose
    .family<ClienteImportacionWeb?, String>((ref, idSistemaUsuario) {
      return ref
          .watch(importacionWebRepositoryProvider)
          .fetchPorUsuario(idSistemaUsuario);
    });
