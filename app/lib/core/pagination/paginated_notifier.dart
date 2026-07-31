import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tamaño de página por defecto para las listas con scroll infinito (estilo Instagram): se
/// cargan de [tamanoPaginaPorDefecto] en [tamanoPaginaPorDefecto] a medida que el usuario se
/// acerca al final de la lista.
const tamanoPaginaPorDefecto = 20;

class PaginaResultado<T> {
  final List<T> items;
  final bool cargandoInicial;
  final bool cargandoMas;
  final bool hasMore;
  final Object? error;

  const PaginaResultado({
    this.items = const [],
    this.cargandoInicial = true,
    this.cargandoMas = false,
    this.hasMore = true,
    this.error,
  });

  PaginaResultado<T> copyWith({List<T>? items, bool? cargandoMas, bool? hasMore}) {
    return PaginaResultado<T>(
      items: items ?? this.items,
      cargandoInicial: false,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notifier base para listas paginadas con scroll infinito: carga la primera página al
/// construirse y expone [cargarMas] para pedir la siguiente cuando la pantalla detecta que el
/// usuario ha llegado al final de la lista ya cargada.
abstract class PaginatedNotifier<T> extends Notifier<PaginaResultado<T>> {
  int get tamanoPagina => tamanoPaginaPorDefecto;

  Future<List<T>> cargarPagina(int offset, int limit);

  @override
  PaginaResultado<T> build() {
    _cargarInicial();
    return const PaginaResultado();
  }

  Future<void> _cargarInicial() async {
    try {
      final items = await cargarPagina(0, tamanoPagina);
      state = PaginaResultado(items: items, cargandoInicial: false, hasMore: items.length >= tamanoPagina);
    } catch (e) {
      state = PaginaResultado(cargandoInicial: false, hasMore: false, error: e);
    }
  }

  Future<void> cargarMas() async {
    final actual = state;
    if (actual.cargandoInicial || actual.cargandoMas || !actual.hasMore) return;
    state = actual.copyWith(cargandoMas: true);
    try {
      final nuevos = await cargarPagina(actual.items.length, tamanoPagina);
      state = state.copyWith(items: [...actual.items, ...nuevos], cargandoMas: false, hasMore: nuevos.length >= tamanoPagina);
    } catch (_) {
      // Si falla la página siguiente dejamos lo ya cargado tal cual: el usuario puede
      // reintentar sin más que volver a hacer scroll hasta el final.
      state = state.copyWith(cargandoMas: false);
    }
  }
}
