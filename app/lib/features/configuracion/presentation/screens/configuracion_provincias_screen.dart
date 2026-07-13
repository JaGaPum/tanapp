import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../application/configuracion_providers.dart';
import '../../data/configuracion_repository.dart';
import '../../data/provincia.dart';

class ConfiguracionProvinciasScreen extends ConsumerWidget {
  const ConfiguracionProvinciasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.configuracionProvinciasTitulo)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: provinciasAsync.when(
        data: (provincias) {
          if (provincias.isEmpty) {
            return EmptyState(message: context.l10n.noHayProvinciasDadasDeAlta, icon: Icons.map_outlined);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(provinciasProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provincias.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final provincia = provincias[index];
                return Card(
                  child: ListTile(
                    title: Text(provincia.nombre),
                    subtitle: Text(context.l10n.prefijoPostalLabel(provincia.prefijoPostal)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: context.l10n.editar,
                          onPressed: () => _mostrarFormulario(context, ref, provincia: provincia),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: context.l10n.eliminar,
                          onPressed: () => _eliminar(context, ref, provincia),
                        ),
                      ],
                    ),
                    onTap: () =>
                        context.push('/admin/configuracion/provincias/${provincia.idConfiguracionProvincia}'),
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

  Future<void> _eliminar(BuildContext context, WidgetRef ref, Provincia provincia) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.provinciaEliminarTitulo,
      message: context.l10n.provinciaEliminarMensaje(provincia.nombre),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref.read(configuracionRepositoryProvider).eliminarProvincia(provincia.idConfiguracionProvincia);
    ref.invalidate(provinciasProvider);
  }

  Future<void> _mostrarFormulario(BuildContext context, WidgetRef ref, {Provincia? provincia}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ProvinciaFormDialog(provincia: provincia),
    );
    ref.invalidate(provinciasProvider);
  }
}

class _ProvinciaFormDialog extends ConsumerStatefulWidget {
  final Provincia? provincia;
  const _ProvinciaFormDialog({this.provincia});

  @override
  ConsumerState<_ProvinciaFormDialog> createState() => _ProvinciaFormDialogState();
}

class _ProvinciaFormDialogState extends ConsumerState<_ProvinciaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(text: widget.provincia?.nombre ?? '');
  late final _prefijoController = TextEditingController(text: widget.provincia?.prefijoPostal ?? '');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _prefijoController.dispose();
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
      if (widget.provincia == null) {
        await repo.crearProvincia(nombre: _nombreController.text, prefijoPostal: _prefijoController.text);
      } else {
        await repo.actualizarProvincia(
          idConfiguracionProvincia: widget.provincia!.idConfiguracionProvincia,
          nombre: _nombreController.text,
          prefijoPostal: _prefijoController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.provincia == null ? context.l10n.provinciaNueva : context.l10n.provinciaEditar),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _nombreController,
              label: context.l10n.fieldNombre,
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.errorNombreRequerido : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _prefijoController,
              label: context.l10n.fieldPrefijoPostal,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.errorPrefijoRequerido : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.confirmDialogCancel)),
        AppButton(label: context.l10n.guardar, loading: _loading, onPressed: _guardar),
      ],
    );
  }
}
