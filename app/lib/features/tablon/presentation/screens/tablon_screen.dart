import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../publicaciones/application/publicaciones_providers.dart';
import '../../../publicaciones/data/publicacion_con_sede.dart';
import '../../../publicaciones/data/publicaciones_repository.dart';
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
  bool _hayNuevas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_intervaloActualizacion, (_) => _comprobarNuevas());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _comprobarNuevas();
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

  /// Al estilo Twitter: no recarga la lista sola (perdería el scroll y las páginas ya cargadas),
  /// solo mira si lo primero que hay ahora mismo en el servidor es distinto de lo primero que ya
  /// se tiene cargado, y si es así, muestra el botón para que sea el propio usuario quien decida
  /// cuándo saltar arriba a verlas.
  Future<void> _comprobarNuevas() async {
    if (_hayNuevas || _terminoBuscado.isNotEmpty) return;
    final actuales = ref.read(publicacionesTablonProvider).items;
    if (actuales.isEmpty) return;
    try {
      final ultimas = await ref
          .read(publicacionesRepositoryProvider)
          .listTablonPersonalizado(offset: 0, limit: 1);
      if (!mounted || ultimas.isEmpty) return;
      if (ultimas.first.idClientePublicacion !=
          actuales.first.idClientePublicacion) {
        setState(() => _hayNuevas = true);
      }
    } catch (_) {
      // Silencioso: es solo una comprobación en segundo plano, no debe interrumpir al usuario.
    }
  }

  void _cargarNuevas() {
    setState(() => _hayNuevas = false);
    ref.invalidate(publicacionesTablonProvider);
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
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                publicacionesAsync.cargandoInicial
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
                // Al estilo Twitter: no reemplaza la lista sola, solo ofrece saltar arriba a
                // verlas cuando el propio usuario lo decida (ver "_comprobarNuevas").
                if (_hayNuevas && !buscando)
                  Positioned(
                    top: 8,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _cargarNuevas,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.tablonHayNuevas,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
