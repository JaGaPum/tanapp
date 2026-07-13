import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solicitud_cliente.dart';
import '../data/solicitudes_repository.dart';

class SolicitudesEstadoFiltroNotifier extends Notifier<String?> {
  @override
  String? build() => 'PENDIENTE';

  void set(String? estado) => state = estado;
}

final solicitudesEstadoFiltroProvider = NotifierProvider<SolicitudesEstadoFiltroNotifier, String?>(
  SolicitudesEstadoFiltroNotifier.new,
);

final solicitudesListProvider = FutureProvider.autoDispose<List<SolicitudCliente>>((ref) async {
  final estado = ref.watch(solicitudesEstadoFiltroProvider);
  return ref.watch(solicitudesRepositoryProvider).listSolicitudes(estado: estado);
});

final solicitudDetailProvider = FutureProvider.autoDispose.family<SolicitudCliente, String>((ref, id) {
  return ref.watch(solicitudesRepositoryProvider).fetchById(id);
});

/// Cuenta de solicitudes pendientes, para el aviso del admin en la pestaña Avisos.
/// Para usuarios no-admin siempre da 0 (la RLS de TClienteSolicitudes solo deja ver a ADMIN).
final solicitudesPendientesCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final lista = await ref.watch(solicitudesRepositoryProvider).listSolicitudes(estado: 'PENDIENTE');
  return lista.length;
});
