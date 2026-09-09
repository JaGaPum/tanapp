import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_notifier.dart';
import '../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../data/publicacion_con_sede.dart';
import '../data/publicacion_programada.dart';
import '../data/publicaciones_por_mes.dart';
import '../data/publicaciones_repository.dart';

class PublicacionesTablonNotifier
    extends PaginatedNotifier<PublicacionConSede> {
  @override
  Future<List<PublicacionConSede>> cargarPagina(int offset, int limit) {
    return ref
        .read(publicacionesRepositoryProvider)
        .listTablonPersonalizado(offset: offset, limit: limit);
  }
}

final publicacionesTablonProvider =
    NotifierProvider.autoDispose<
      PublicacionesTablonNotifier,
      PaginaResultado<PublicacionConSede>
    >(PublicacionesTablonNotifier.new);

/// Búsqueda en todo el histórico (family por término): a diferencia de [publicacionesTablonProvider],
/// no se limita a lo ya cargado en memoria.
class BusquedaPublicacionesNotifier
    extends PaginatedNotifier<PublicacionConSede> {
  final String termino;
  BusquedaPublicacionesNotifier(this.termino);

  @override
  Future<List<PublicacionConSede>> cargarPagina(int offset, int limit) {
    return ref
        .read(publicacionesRepositoryProvider)
        .buscarHistorico(termino: termino, offset: offset, limit: limit);
  }
}

final busquedaPublicacionesProvider = NotifierProvider.autoDispose
    .family<
      BusquedaPublicacionesNotifier,
      PaginaResultado<PublicacionConSede>,
      String
    >(BusquedaPublicacionesNotifier.new);

final publicacionesPorSedeProvider = FutureProvider.autoDispose
    .family<List<PublicacionConSede>, String>((ref, idClienteSede) {
      return ref.watch(publicacionesRepositoryProvider).listPorSedes([
        idClienteSede,
      ]);
    });

final misPublicacionesProvider =
    FutureProvider.autoDispose<List<PublicacionConSede>>((ref) async {
      final sedes = await ref.watch(misSedesProvider.future);
      return ref
          .watch(publicacionesRepositoryProvider)
          .listPorSedes(sedes.map((s) => s.idClienteSede).toList());
    });

final misPublicacionesArchivadasIdsProvider =
    FutureProvider.autoDispose<Set<String>>((ref) {
      return ref.watch(publicacionesRepositoryProvider).listMisArchivadasIds();
    });

class PublicacionesArchivadasNotifier
    extends PaginatedNotifier<PublicacionConSede> {
  @override
  Future<List<PublicacionConSede>> cargarPagina(int offset, int limit) {
    return ref
        .read(publicacionesRepositoryProvider)
        .listMisArchivadas(offset: offset, limit: limit);
  }
}

final misPublicacionesArchivadasProvider =
    NotifierProvider.autoDispose<
      PublicacionesArchivadasNotifier,
      PaginaResultado<PublicacionConSede>
    >(PublicacionesArchivadasNotifier.new);

/// Publicaciones programadas (055) de todas mis sedes, pendientes de que llegue su fecha.
final misPublicacionesProgramadasProvider =
    FutureProvider.autoDispose<List<PublicacionProgramada>>((ref) async {
      final sedes = await ref.watch(misSedesProvider.future);
      return ref
          .watch(publicacionesRepositoryProvider)
          .listPublicacionesProgramadas(
            sedes.map((s) => s.idClienteSede).toList(),
          );
    });

/// Si una esquela admite condolencias y si son obligatoriamente privadas (069), para informar en
/// la pantalla de condolencias antes de dejar que el seguidor escriba la suya.
final configCondolenciasProvider = FutureProvider.autoDispose
    .family<({bool admiteCondolencias, bool soloPrivadas}), String>((
      ref,
      idClientePublicacion,
    ) {
      return ref
          .watch(publicacionesRepositoryProvider)
          .fetchConfigCondolencias(idClientePublicacion);
    });

/// Actividad de publicaciones de los últimos meses, para la gráfica del Panel de Datos.
final publicacionesPorMesProvider =
    FutureProvider.autoDispose<List<PublicacionesPorMes>>((ref) async {
      final sedes = await ref.watch(misSedesProvider.future);
      return ref
          .watch(publicacionesRepositoryProvider)
          .listPublicacionesPorMes(sedes.map((s) => s.idClienteSede).toList());
    });
