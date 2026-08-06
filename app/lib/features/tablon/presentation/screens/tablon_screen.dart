import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../publicaciones/data/publicacion_con_sede.dart';
import '../../../publicaciones/presentation/widgets/publicacion_card.dart';

const _intervaloActualizacion = Duration(seconds: 30);
const _debounceBusqueda = Duration(milliseconds: 400);

class TablonScreen extends ConsumerStatefulWidget {
  const TablonScreen({super.key});

  @override
  ConsumerState<TablonScreen> createState() => _TablonScreenState();
}

class _TablonScreenState extends ConsumerState<TablonScreen>
    with WidgetsBindingObserver {
  final _busquedaController = TextEditingController();
  Timer? _timer;
  Timer? _debounce;
  String _terminoBuscado = '';
  bool _mostrarFiltros = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      _intervaloActualizacion,
      (_) => ref.invalidate(publicacionesTablonProvider),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(publicacionesTablonProvider);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _busquedaController.dispose();
    super.dispose();
  }

  void _alCambiarBusqueda() {
    _debounce?.cancel();
    _debounce = Timer(_debounceBusqueda, () {
      if (mounted) {
        setState(() => _terminoBuscado = _busquedaController.text.trim());
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final escala = ref.watch(escalaTextoProvider);
    final notifierEscala = ref.read(escalaTextoProvider.notifier);
    final buscando = _terminoBuscado.isNotEmpty;
    final publicacionesAsync = buscando
        ? ref.watch(busquedaPublicacionesProvider(_terminoBuscado))
        : ref.watch(publicacionesTablonProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _mostrarFiltros = !_mostrarFiltros),
                  icon: Icon(
                    _mostrarFiltros ? Icons.expand_less : Icons.search,
                  ),
                  label: Text(context.l10n.filtrar),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_decrease, size: 20),
                tooltip: context.l10n.tablonDisminuirLetra,
                onPressed: escala == EscalaTextoNotifier.valores.first
                    ? null
                    : notifierEscala.disminuir,
              ),
              IconButton(
                icon: const Icon(Icons.text_increase, size: 30),
                tooltip: context.l10n.tablonAumentarLetra,
                onPressed: escala == EscalaTextoNotifier.valores.last
                    ? null
                    : notifierEscala.aumentar,
              ),
            ],
          ),
          if (_mostrarFiltros) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: context.l10n.tablonBuscar,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => _alCambiarBusqueda(),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: publicacionesAsync.cargandoInicial
                ? const Center(child: CircularProgressIndicator())
                : publicacionesAsync.error != null
                ? Center(
                    child: Text(
                      context.l10n.errorGenerico(
                        publicacionesAsync.error.toString(),
                      ),
                    ),
                  )
                : publicacionesAsync.items.isEmpty
                ? EmptyState(
                    message: buscando
                        ? context.l10n.tablonSinResultados
                        : context.l10n.tablonVacioSinSeguir,
                    icon: Icons.dynamic_feed_outlined,
                  )
                : PaginatedListView<PublicacionConSede>(
                    items: publicacionesAsync.items,
                    cargandoMas: publicacionesAsync.cargandoMas,
                    hasMore: publicacionesAsync.hasMore,
                    onCargarMas: () => buscando
                        ? ref
                              .read(
                                busquedaPublicacionesProvider(
                                  _terminoBuscado,
                                ).notifier,
                              )
                              .cargarMas()
                        : ref
                              .read(publicacionesTablonProvider.notifier)
                              .cargarMas(),
                    itemBuilder: (context, publicacion) =>
                        PublicacionCard(publicacion: publicacion),
                  ),
          ),
        ],
      ),
    );
  }
}
