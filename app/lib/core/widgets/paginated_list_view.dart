import 'package:flutter/material.dart';

/// Lista con scroll infinito estilo Instagram: pinta [items] (ya filtrados si procede) y, cuando
/// el usuario se acerca al final, llama a [onCargarMas] para pedir la siguiente página. Mientras
/// [cargandoMas] es true muestra un indicador al final de la lista.
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final bool cargandoMas;
  final bool hasMore;
  final VoidCallback onCargarMas;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.cargandoMas,
    required this.hasMore,
    required this.onCargarMas,
    required this.itemBuilder,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  static const _umbral = 200.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.cargandoMas || !widget.hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _umbral) {
      widget.onCargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      // Muchas pantallas que usan esta lista no tienen barra de navegación inferior propia (no
      // son una de las pestañas de HomeScreen), así que sin esto el último elemento queda medio
      // tapado por la barra de gestos/navegación del móvil.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      itemCount: widget.items.length + (widget.cargandoMas ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }
}
