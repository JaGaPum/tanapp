import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/device_sesion_store.dart';
import '../data/sesion.dart';
import '../data/sesiones_repository.dart';

final usuarioSesionesProvider = FutureProvider.autoDispose
    .family<List<Sesion>, String>((ref, idSistemaUsuario) {
      return ref
          .watch(sesionesRepositoryProvider)
          .listSesionesUsuario(idSistemaUsuario);
    });

/// La fila de "TSistemaSesiones" que corresponde a ESTE dispositivo (ver [DeviceSesionStore]),
/// null si todavía no hay ninguna sesión app registrada (p. ej. justo tras un login que aún no
/// ha terminado de registrarse). Se recalcula en cualquier cambio de sesión de Supabase Auth
/// (login, logout, suplantación) porque el id guardado en local puede pasar a corresponder a
/// otro usuario.
final sesionActualProvider = FutureProvider.autoDispose<Sesion?>((ref) async {
  ref.watch(authStateChangesProvider);
  final idLocal = await ref.watch(deviceSesionStoreProvider).leer();
  if (idLocal == null) return null;
  return ref.watch(sesionesRepositoryProvider).fetchPorId(idLocal);
});

/// Todas las sesiones abiertas de todos los usuarios, para la pestaña "En vivo" del admin.
final sesionesAbiertasProvider =
    FutureProvider.autoDispose<List<SesionAbierta>>((ref) {
      return ref.watch(sesionesRepositoryProvider).listSesionesAbiertas();
    });
