import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/pagination/paginated_notifier.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/vela_icon.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../application/condolencias_providers.dart';
import '../../data/condolencia.dart';
import '../../data/condolencias_repository.dart';
import '../widgets/exportar_condolencias_button.dart';

class CondolenciasScreen extends ConsumerWidget {
  final String idClientePublicacion;
  final String nombreFallecido;
  final String idClienteSede;

  const CondolenciasScreen({
    super.key,
    required this.idClientePublicacion,
    required this.nombreFallecido,
    required this.idClienteSede,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esDueno = ref
        .watch(misSedesProvider)
        .maybeWhen(
          data: (sedes) => sedes.any((s) => s.idClienteSede == idClienteSede),
          orElse: () => false,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.condolenciasTitulo(nombreFallecido)),
      ),
      body: _Cuerpo(
        idClientePublicacion: idClientePublicacion,
        nombreFallecido: nombreFallecido,
        mostrarExportar: esDueno,
      ),
    );
  }
}

class _Cuerpo extends ConsumerStatefulWidget {
  final String idClientePublicacion;
  final String nombreFallecido;
  final bool mostrarExportar;
  const _Cuerpo({
    required this.idClientePublicacion,
    required this.nombreFallecido,
    required this.mostrarExportar,
  });

  @override
  ConsumerState<_Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends ConsumerState<_Cuerpo> {
  final _textoController = TextEditingController();
  bool _editando = false;
  bool _guardando = false;

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _refrescar() async {
    ref.invalidate(miCondolenciaProvider(widget.idClientePublicacion));
    ref.invalidate(condolenciasProvider(widget.idClientePublicacion));
  }

  Future<void> _guardar(Condolencia? propia) async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;
    setState(() => _guardando = true);
    try {
      final repo = ref.read(condolenciasRepositoryProvider);
      if (propia != null) {
        await repo.actualizarCondolencia(
          idClientePublicacionCondolencia:
              propia.idClientePublicacionCondolencia,
          texto: texto,
        );
      } else {
        await repo.crearCondolencia(
          idClientePublicacion: widget.idClientePublicacion,
          texto: texto,
        );
      }
      await _refrescar();
      if (mounted) setState(() => _editando = false);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminar(Condolencia propia) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.condolenciasEliminarTitulo,
      message: context.l10n.condolenciasEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(condolenciasRepositoryProvider)
          .eliminarCondolencia(propia.idClientePublicacionCondolencia);
      _textoController.clear();
      await _refrescar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final miCondolenciaAsync = ref.watch(
      miCondolenciaProvider(widget.idClientePublicacion),
    );
    final resultado = ref.watch(
      condolenciasProvider(widget.idClientePublicacion),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.mostrarExportar) ...[
            ExportarCondolenciasButton(
              idClientePublicacion: widget.idClientePublicacion,
              nombreFallecido: widget.nombreFallecido,
            ),
            const SizedBox(height: 20),
          ],
          miCondolenciaAsync.when(
            data: (propia) {
              if (!_editando) {
                _textoController.text = propia?.texto ?? '';
              }
              return _MiCondolencia(
                propia: propia,
                editando: _editando,
                guardando: _guardando,
                controller: _textoController,
                onEditar: () => setState(() => _editando = true),
                onCancelar: () => setState(() {
                  _editando = false;
                  _textoController.text = propia?.texto ?? '';
                }),
                onGuardar: () => _guardar(propia),
                onEliminar: propia == null ? null : () => _eliminar(propia),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.condolenciasTodas,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          _ListaCondolencias(
            resultado: resultado,
            idMiCondolencia:
                miCondolenciaAsync.value?.idClientePublicacionCondolencia,
            onCargarMas: () => ref
                .read(
                  condolenciasProvider(widget.idClientePublicacion).notifier,
                )
                .cargarMas(),
          ),
        ],
      ),
    );
  }
}

class _MiCondolencia extends StatelessWidget {
  final Condolencia? propia;
  final bool editando;
  final bool guardando;
  final TextEditingController controller;
  final VoidCallback onEditar;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;
  final VoidCallback? onEliminar;

  const _MiCondolencia({
    required this.propia,
    required this.editando,
    required this.guardando,
    required this.controller,
    required this.onEditar,
    required this.onCancelar,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarFormulario = editando || propia == null;
    return Card(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.condolenciasTuCondolencia,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (mostrarFormulario) ...[
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.condolenciasEscribeAqui,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (propia != null) ...[
                    Expanded(
                      child: AppButton(
                        label: context.l10n.confirmDialogCancel,
                        secondary: true,
                        onPressed: onCancelar,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: AppButton(
                      label: context.l10n.guardar,
                      loading: guardando,
                      onPressed: onGuardar,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(propia!.texto, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(context.l10n.editar),
                    onPressed: onEditar,
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.l10n.eliminar),
                    onPressed: onEliminar,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListaCondolencias extends StatelessWidget {
  final PaginaResultado<Condolencia> resultado;
  final String? idMiCondolencia;
  final VoidCallback onCargarMas;

  const _ListaCondolencias({
    required this.resultado,
    required this.idMiCondolencia,
    required this.onCargarMas,
  });

  @override
  Widget build(BuildContext context) {
    if (resultado.cargandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (resultado.error != null) {
      return Text(context.l10n.errorGenerico(resultado.error.toString()));
    }
    // La propia condolencia ya se ve arriba, con sus controles: no se repite aquí.
    final items = resultado.items
        .where((c) => c.idClientePublicacionCondolencia != idMiCondolencia)
        .toList();
    if (items.isEmpty) {
      return EmptyState(
        message: context.l10n.condolenciasVacio,
        iconWidget: VelaIcon(
          size: 40,
          colorCuerpo: Theme.of(context).colorScheme.secondary,
          colorLlama: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PaginatedListView<Condolencia>(
        items: items,
        cargandoMas: resultado.cargandoMas,
        hasMore: resultado.hasMore,
        onCargarMas: onCargarMas,
        itemBuilder: (context, condolencia) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condolencia.nombreAutor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  condolencia.texto,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(condolencia.fechaAlta.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
