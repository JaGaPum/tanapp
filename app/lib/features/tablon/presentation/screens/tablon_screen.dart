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

class TablonScreen extends ConsumerStatefulWidget {
  const TablonScreen({super.key});

  @override
  ConsumerState<TablonScreen> createState() => _TablonScreenState();
}

class _TablonScreenState extends ConsumerState<TablonScreen> with WidgetsBindingObserver {
  final _busquedaController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_intervaloActualizacion, (_) => ref.invalidate(publicacionesTablonProvider));
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
    WidgetsBinding.instance.removeObserver(this);
    _busquedaController.dispose();
    super.dispose();
  }

  List<PublicacionConSede> _filtrar(List<PublicacionConSede> publicaciones) {
    final termino = _busquedaController.text.trim().toLowerCase();
    if (termino.isEmpty) return publicaciones;
    return publicaciones.where((p) {
      return p.nombreFallecido.toLowerCase().contains(termino) ||
          (p.iglesia?.toLowerCase().contains(termino) ?? false) ||
          (p.lugar?.toLowerCase().contains(termino) ?? false) ||
          (p.capillaArdiente?.toLowerCase().contains(termino) ?? false) ||
          (p.sala?.toLowerCase().contains(termino) ?? false) ||
          (p.observaciones?.toLowerCase().contains(termino) ?? false) ||
          p.nombreCliente.toLowerCase().contains(termino) ||
          p.concello.toLowerCase().contains(termino);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final publicacionesAsync = ref.watch(publicacionesTablonProvider);
    final escala = ref.watch(escalaTextoProvider);
    final notifierEscala = ref.read(escalaTextoProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    labelText: context.l10n.tablonBuscar,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_decrease, size: 20),
                tooltip: context.l10n.tablonDisminuirLetra,
                onPressed: escala == EscalaTextoNotifier.valores.first ? null : notifierEscala.disminuir,
              ),
              IconButton(
                icon: const Icon(Icons.text_increase, size: 30),
                tooltip: context.l10n.tablonAumentarLetra,
                onPressed: escala == EscalaTextoNotifier.valores.last ? null : notifierEscala.aumentar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: publicacionesAsync.cargandoInicial
                ? const Center(child: CircularProgressIndicator())
                : publicacionesAsync.error != null
                    ? Center(child: Text(context.l10n.errorGenerico(publicacionesAsync.error.toString())))
                    : Builder(
                        builder: (context) {
                          final filtradas = _filtrar(publicacionesAsync.items);
                          if (filtradas.isEmpty) {
                            return EmptyState(
                              message: context.l10n.publicarSinPublicaciones,
                              icon: Icons.dynamic_feed_outlined,
                            );
                          }
                          return PaginatedListView<PublicacionConSede>(
                            items: filtradas,
                            cargandoMas: publicacionesAsync.cargandoMas,
                            hasMore: publicacionesAsync.hasMore,
                            onCargarMas: () => ref.read(publicacionesTablonProvider.notifier).cargarMas(),
                            itemBuilder: (context, publicacion) => PublicacionCard(publicacion: publicacion),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
