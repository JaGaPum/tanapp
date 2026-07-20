import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              labelText: context.l10n.tablonBuscar,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: publicacionesAsync.when(
              data: (publicaciones) {
                final filtradas = _filtrar(publicaciones);
                if (filtradas.isEmpty) {
                  return EmptyState(message: context.l10n.publicarSinPublicaciones, icon: Icons.dynamic_feed_outlined);
                }
                return ListView.separated(
                  itemCount: filtradas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => PublicacionCard(publicacion: filtradas[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}
