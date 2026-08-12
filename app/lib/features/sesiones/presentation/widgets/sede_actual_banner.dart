import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../../cliente_sedes/data/cliente_sede.dart';
import '../../application/elegir_sede.dart';
import '../../application/sesiones_providers.dart';
import '../../data/sesion.dart';

/// Franja fija con la sede que tiene asignada esta sesión y un botón para cambiarla en
/// cualquier momento. Solo se muestra a un CLIENTE con más de una sede: con una sola no hay
/// nada entre lo que elegir.
class SedeActualBanner extends ConsumerWidget {
  const SedeActualBanner({super.key});

  Future<void> _cambiar(BuildContext context, WidgetRef ref) async {
    try {
      final sesionActual = await ref.read(sesionActualProvider.future);
      final sedes = await ref.read(misSedesProvider.future);
      if (!context.mounted) return;
      if (sesionActual == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorInesperado)));
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            _SelectorSedes(sesionActual: sesionActual, sedes: sedes),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGenerico(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCliente = ref.watch(isClienteProvider);
    final sedes = ref.watch(misSedesProvider).value ?? const <ClienteSede>[];
    final sesionActual = ref.watch(sesionActualProvider).value;
    if (!isCliente || sedes.length < 2) return const SizedBox.shrink();

    final nombreSede = sedes
        .where((s) => s.idClienteSede == sesionActual?.idClienteSede)
        .map((s) => s.nombre)
        .firstOrNull;

    return Material(
      color: AppColors.plumLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.sedeActualTexto(nombreSede ?? ''),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => _cambiar(context, ref),
              child: Text(context.l10n.sedeActualCambiar),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorSedes extends ConsumerStatefulWidget {
  final Sesion sesionActual;
  final List<ClienteSede> sedes;
  const _SelectorSedes({required this.sesionActual, required this.sedes});

  @override
  ConsumerState<_SelectorSedes> createState() => _SelectorSedesState();
}

class _SelectorSedesState extends ConsumerState<_SelectorSedes> {
  String? _idSedeEligiendo;
  String? _error;

  Future<void> _elegir(ClienteSede sede) async {
    setState(() {
      _idSedeEligiendo = sede.idClienteSede;
      _error = null;
    });
    try {
      final asignada = await elegirSedeParaSesion(
        context: context,
        ref: ref,
        sesionActual: widget.sesionActual,
        sede: sede,
      );
      if (!mounted) return;
      if (asignada) {
        Navigator.of(context).pop();
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = context.l10n.errorGenerico(e.toString()));
      }
    }
    if (mounted) setState(() => _idSedeEligiendo = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.sedeActualCambiar,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 8),
            for (final sede in widget.sedes)
              Card(
                child: ListTile(
                  title: Text(sede.nombre),
                  subtitle: Text('${sede.codigo} · ${sede.concello}'),
                  selected:
                      sede.idClienteSede == widget.sesionActual.idClienteSede,
                  trailing: _idSedeEligiendo == sede.idClienteSede
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _idSedeEligiendo == null ? () => _elegir(sede) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
