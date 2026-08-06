import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_notifier.dart';
import '../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../zonas_seguidas/data/zonas_seguidas_repository.dart';
import '../data/cliente_seguible.dart';
import '../data/seguidores_resumen.dart';
import '../data/seguidos_repository.dart';
import '../data/seguimiento_sede_info.dart';

class ClientesFiltro {
  final String idConfiguracionClienteTipo;
  final String provincia;
  final String concello;

  const ClientesFiltro({
    required this.idConfiguracionClienteTipo,
    required this.provincia,
    required this.concello,
  });

  @override
  bool operator ==(Object other) =>
      other is ClientesFiltro &&
      other.idConfiguracionClienteTipo == idConfiguracionClienteTipo &&
      other.provincia == provincia &&
      other.concello == concello;

  @override
  int get hashCode =>
      Object.hash(idConfiguracionClienteTipo, provincia, concello);
}

final clientesPorFiltroProvider = FutureProvider.autoDispose
    .family<List<ClienteSeguible>, ClientesFiltro>((ref, filtro) {
      return ref
          .watch(seguidosRepositoryProvider)
          .listClientesPorFiltro(
            idConfiguracionClienteTipo: filtro.idConfiguracionClienteTipo,
            provincia: filtro.provincia,
            concello: filtro.concello,
          );
    });

final misSeguidosIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) {
  return ref.watch(seguidosRepositoryProvider).listMisSeguidosIds();
});

class MisSeguidosClientesNotifier extends PaginatedNotifier<ClienteSeguible> {
  @override
  Future<List<ClienteSeguible>> cargarPagina(int offset, int limit) {
    return ref
        .read(seguidosRepositoryProvider)
        .listMisSeguidosClientes(offset: offset, limit: limit);
  }
}

final misSeguidosClientesProvider =
    NotifierProvider.autoDispose<
      MisSeguidosClientesNotifier,
      PaginaResultado<ClienteSeguible>
    >(MisSeguidosClientesNotifier.new);

/// Clave usada para agrupar seguidores que no tienen concello indicado en su perfil.
const seguidorSinConcello = '';

/// Un seguimiento por fila (seguidor + sede propia que sigue): base compartida para el desglose
/// por sede y para el total único por cliente (un mismo seguidor que sigue dos sedes del mismo
/// cliente no debe contar como dos seguidores distintos).
final misSeguidoresFilasProvider =
    FutureProvider.autoDispose<List<SeguimientoSedeInfo>>((ref) async {
      final sedes = await ref.watch(misSedesProvider.future);
      return ref
          .watch(seguidosRepositoryProvider)
          .listSeguidoresPorSedes(sedes.map((s) => s.idClienteSede).toList());
    });

final misSeguidoresPorSedeProvider =
    FutureProvider.autoDispose<List<SeguidoresPorSede>>((ref) async {
      final sedes = await ref.watch(misSedesProvider.future);
      final filas = await ref.watch(misSeguidoresFilasProvider.future);
      final zonaConteos = await ref
          .watch(zonasSeguidasRepositoryProvider)
          .contarPorConcellos(sedes.map((s) => s.concello).toSet().toList());

      return sedes.map((sede) {
        final propias = filas
            .where((f) => f.idClienteSede == sede.idClienteSede)
            .toList();
        final porConcello = <String, int>{};
        for (final fila in propias) {
          final clave = fila.concelloSeguidor ?? seguidorSinConcello;
          porConcello[clave] = (porConcello[clave] ?? 0) + 1;
        }
        final ordenado = porConcello.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return SeguidoresPorSede(
          idClienteSede: sede.idClienteSede,
          codigoSede: sede.codigo,
          nombreSede: sede.nombre,
          total: propias.length,
          porConcello: ordenado,
          zonaSeguidores: zonaConteos[sede.concello] ?? 0,
        );
      }).toList();
    });

/// Total de seguidores distintos del cliente contando todas sus sedes: si un mismo seguidor
/// sigue dos sedes, cuenta una sola vez aquí (a diferencia de la suma de los totales por sede).
final misSeguidoresTotalUnicoProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final filas = await ref.watch(misSeguidoresFilasProvider.future);
  return filas.map((f) => f.idSistemaUsuario).toSet().length;
});
