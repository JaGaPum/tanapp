import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_notifier.dart';
import '../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../data/aviso_estadistica.dart';
import '../data/aviso_recibido.dart';
import '../data/avisos_repository.dart';
import '../data/cliente_aviso.dart';

class MisAvisosEnviadosNotifier extends PaginatedNotifier<ClienteAviso> {
  @override
  Future<List<ClienteAviso>> cargarPagina(int offset, int limit) async {
    final sedes = await ref.read(misSedesProvider.future);
    return ref.read(avisosRepositoryProvider).listMisAvisosEnviados(
          sedes.map((s) => s.idClienteSede).toList(),
          offset: offset,
          limit: limit,
        );
  }
}

final misAvisosEnviadosProvider =
    NotifierProvider.autoDispose<MisAvisosEnviadosNotifier, PaginaResultado<ClienteAviso>>(
  MisAvisosEnviadosNotifier.new,
);

class MisAvisosRecibidosNotifier extends PaginatedNotifier<AvisoRecibido> {
  @override
  Future<List<AvisoRecibido>> cargarPagina(int offset, int limit) {
    return ref.read(avisosRepositoryProvider).listMisAvisosRecibidos(offset: offset, limit: limit);
  }
}

final misAvisosRecibidosProvider =
    NotifierProvider.autoDispose<MisAvisosRecibidosNotifier, PaginaResultado<AvisoRecibido>>(
  MisAvisosRecibidosNotifier.new,
);

final avisosNoLeidosCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(avisosRepositoryProvider).contarAvisosNoLeidos();
});

/// Estadísticas de los últimos avisos enviados (recibidos/leídos), para la gráfica del Panel
/// de Datos del cliente.
final avisosEstadisticasProvider = FutureProvider.autoDispose<List<AvisoEstadistica>>((ref) async {
  final sedes = await ref.watch(misSedesProvider.future);
  return ref.watch(avisosRepositoryProvider).listEstadisticasAvisos(sedes.map((s) => s.idClienteSede).toList());
});
