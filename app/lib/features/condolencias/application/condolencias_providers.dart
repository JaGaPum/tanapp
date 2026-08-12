import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_notifier.dart';
import '../../publicaciones/application/publicaciones_providers.dart';
import '../../publicaciones/data/publicaciones_por_mes.dart';
import '../data/condolencia.dart';
import '../data/condolencias_repository.dart';

class CondolenciasNotifier extends PaginatedNotifier<Condolencia> {
  final String idClientePublicacion;
  CondolenciasNotifier(this.idClientePublicacion);

  @override
  Future<List<Condolencia>> cargarPagina(int offset, int limit) {
    return ref
        .read(condolenciasRepositoryProvider)
        .listCondolencias(idClientePublicacion, offset: offset, limit: limit);
  }
}

final condolenciasProvider = NotifierProvider.autoDispose
    .family<CondolenciasNotifier, PaginaResultado<Condolencia>, String>(
      CondolenciasNotifier.new,
    );

/// Independiente de la paginación de [condolenciasProvider]: la propia condolencia del usuario
/// actual (o null si no ha dejado ninguna), para saber si mostrar "crear" o "editar".
final miCondolenciaProvider = FutureProvider.autoDispose
    .family<Condolencia?, String>((ref, idClientePublicacion) {
      return ref
          .watch(condolenciasRepositoryProvider)
          .fetchMiCondolencia(idClientePublicacion);
    });

/// Todas de golpe, para la vista previa en modal (Taboleiro, Arquivo...): la lista suele ser
/// corta y así no hace falta montar la paginación de [condolenciasProvider] solo para un vistazo.
final condolenciasVistaPreviaProvider = FutureProvider.autoDispose
    .family<List<Condolencia>, String>((ref, idClientePublicacion) {
      return ref
          .watch(condolenciasRepositoryProvider)
          .listTodasCondolencias(idClientePublicacion);
    });

/// Condolencias por mes en las publicaciones propias del cliente, para el Panel de Datos
/// (dentro de "Publicaciones", junto a "publicaciones por mes").
final condolenciasPorMesProvider =
    FutureProvider.autoDispose<List<PublicacionesPorMes>>((ref) async {
      final publicaciones = await ref.watch(misPublicacionesProvider.future);
      final ids = publicaciones.map((p) => p.idClientePublicacion).toList();
      return ref
          .watch(condolenciasRepositoryProvider)
          .listCondolenciasPorMes(ids);
    });
