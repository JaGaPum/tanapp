import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_notifier.dart';
import '../data/recordatorio_publicacion.dart';
import '../data/recordatorios_repository.dart';

/// Recordatorios pendientes del usuario actual para una publicación concreta (070), para el
/// diálogo de "configurar recordatorio" de su tarjeta.
final recordatoriosPendientesPorPublicacionProvider = FutureProvider.autoDispose
    .family<List<RecordatorioPublicacion>, String>((ref, idClientePublicacion) {
      return ref
          .watch(recordatoriosRepositoryProvider)
          .listPendientesPorPublicacion(idClientePublicacion);
    });

/// Todos los recordatorios pendientes del usuario actual, de cualquier publicación, para "Mis
/// recordatorios".
final misRecordatoriosPendientesProvider =
    FutureProvider.autoDispose<List<RecordatorioPublicacion>>((ref) {
      return ref.watch(recordatoriosRepositoryProvider).listMisPendientes();
    });

class RecordatoriosEnviadosNotifier
    extends PaginatedNotifier<RecordatorioPublicacion> {
  @override
  Future<List<RecordatorioPublicacion>> cargarPagina(int offset, int limit) {
    return ref
        .read(recordatoriosRepositoryProvider)
        .listMisEnviados(offset: offset, limit: limit);
  }
}

final recordatoriosEnviadosProvider =
    NotifierProvider.autoDispose<
      RecordatoriosEnviadosNotifier,
      PaginaResultado<RecordatorioPublicacion>
    >(RecordatoriosEnviadosNotifier.new);

/// Recordatorios ya enviados y sin abrir, para el badge de la pestaña "Avisos".
final recordatoriosNoLeidosCountProvider = FutureProvider.autoDispose<int>((
  ref,
) {
  return ref.watch(recordatoriosRepositoryProvider).contarNoLeidos();
});

typedef RecordatorioTocado = ({
  String idClientePublicacion,
  String idClientePublicacionRecordatorio,
});

/// Qué publicación mostrar en cuanto la pantalla de Avisos > Recibidos esté montada: la fija
/// HomeScreen al tocar la notificación de un recordatorio (070), y AvisosScreen la consume una
/// sola vez (la vuelve a poner a null) para no reabrir el mismo diálogo en cada rebuild.
class RecordatorioNotificacionTocadaNotifier
    extends Notifier<RecordatorioTocado?> {
  @override
  RecordatorioTocado? build() => null;

  void fijar(RecordatorioTocado valor) => state = valor;

  void consumir() => state = null;
}

final recordatorioNotificacionTocadaProvider =
    NotifierProvider<
      RecordatorioNotificacionTocadaNotifier,
      RecordatorioTocado?
    >(RecordatorioNotificacionTocadaNotifier.new);
