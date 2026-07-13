import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../application/configuracion_providers.dart';
import '../../data/concello.dart';
import '../../data/configuracion_repository.dart';

class ConfiguracionConcellosScreen extends ConsumerWidget {
  final String idConfiguracionProvincia;
  const ConfiguracionConcellosScreen({super.key, required this.idConfiguracionProvincia});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);
    final concellosAsync = ref.watch(concellosPorProvinciaProvider(idConfiguracionProvincia));
    final nombreProvincia = provinciasAsync.maybeWhen(
      data: (provincias) => provincias
          .where((p) => p.idConfiguracionProvincia == idConfiguracionProvincia)
          .map((p) => p.nombre)
          .firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombreProvincia != null
              ? context.l10n.concellosDeProvincia(nombreProvincia)
              : context.l10n.concellosTitulo,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: concellosAsync.when(
        data: (concellos) {
          if (concellos.isEmpty) {
            return EmptyState(message: context.l10n.noHayConcellosDadosDeAlta, icon: Icons.location_city_outlined);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(concellosPorProvinciaProvider(idConfiguracionProvincia).future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: concellos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final concello = concellos[index];
                return Card(
                  child: ListTile(
                    title: Text(concello.nombre),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: context.l10n.editar,
                          onPressed: () => _mostrarFormulario(context, ref, concello: concello),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.eliminar,
                          onPressed: () => _eliminar(context, ref, concello),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref, Concello concello) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.concelloEliminarTitulo,
      message: context.l10n.concelloEliminarMensaje(concello.nombre),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref.read(configuracionRepositoryProvider).eliminarConcello(concello.idConfiguracionConcello);
    ref.invalidate(concellosPorProvinciaProvider(idConfiguracionProvincia));
  }

  Future<void> _mostrarFormulario(BuildContext context, WidgetRef ref, {Concello? concello}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ConcelloFormDialog(
        idConfiguracionProvincia: idConfiguracionProvincia,
        concello: concello,
      ),
    );
    ref.invalidate(concellosPorProvinciaProvider(idConfiguracionProvincia));
  }
}

class _ConcelloFormDialog extends ConsumerStatefulWidget {
  final String idConfiguracionProvincia;
  final Concello? concello;
  const _ConcelloFormDialog({required this.idConfiguracionProvincia, this.concello});

  @override
  ConsumerState<_ConcelloFormDialog> createState() => _ConcelloFormDialogState();
}

class _ConcelloFormDialogState extends ConsumerState<_ConcelloFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(text: widget.concello?.nombre ?? '');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(configuracionRepositoryProvider);
    try {
      if (widget.concello == null) {
        await repo.crearConcello(idConfiguracionProvincia: widget.idConfiguracionProvincia, nombre: _nombreController.text);
      } else {
        await repo.actualizarConcello(
          idConfiguracionConcello: widget.concello!.idConfiguracionConcello,
          nombre: _nombreController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : 'Ha ocurrido un error inesperado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.concello == null ? 'Nuevo concello' : 'Editar concello'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _nombreController,
              label: 'Nombre',
              validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        AppButton(label: 'Guardar', loading: _loading, onPressed: _guardar),
      ],
    );
  }
}
