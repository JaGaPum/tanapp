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
        esDueno: esDueno,
      ),
    );
  }
}

class _Cuerpo extends ConsumerStatefulWidget {
  final String idClientePublicacion;
  final String nombreFallecido;
  final bool esDueno;
  const _Cuerpo({
    required this.idClientePublicacion,
    required this.nombreFallecido,
    required this.esDueno,
  });

  @override
  ConsumerState<_Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends ConsumerState<_Cuerpo> {
  final _textoController = TextEditingController();
  bool _editando = false;
  bool _guardando = false;
  bool _anonima = false;
  bool _privada = false;
  // Evita que el sincronizado inicial de abajo (texto/anónima/privada desde el servidor) se
  // repita en cada "build" -p. ej. al marcar un checkbox, que hace setState- y deshaga lo que
  // se acaba de escribir o marcar: solo hace falta la primera vez que llega "propia".
  bool _cargado = false;

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
          anonima: _anonima,
          privada: _privada,
        );
      } else {
        await repo.crearCondolencia(
          idClientePublicacion: widget.idClientePublicacion,
          texto: texto,
          anonima: _anonima,
          privada: _privada,
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
      _anonima = false;
      _privada = false;
      await _refrescar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Moderación del dueño de la esquela sobre una condolencia ajena: borrado lógico, con aviso
  /// para quien la escribió (ver la vista "VClientePublicacionesCondolencias" en 050).
  Future<void> _moderarEliminar(Condolencia condolencia) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.condolenciasModerarEliminarTitulo,
      message: context.l10n.condolenciasModerarEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    await ref
        .read(condolenciasRepositoryProvider)
        .moderarEliminar(condolencia.idClientePublicacionCondolencia);
    await _refrescar();
  }

  /// Moderación del dueño de la esquela: reescribe el texto de una condolencia ajena (p. ej.
  /// para quitar una parte inapropiada sin borrarla entera).
  Future<void> _moderarEditar(Condolencia condolencia) async {
    final controller = TextEditingController(text: condolencia.texto);
    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.condolenciasModerarEditarTitulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.condolenciasModerarEditarAyuda,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(controller: controller, maxLines: 4, autofocus: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.confirmDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.l10n.guardar),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nuevoTexto == null || nuevoTexto.isEmpty) return;
    await ref
        .read(condolenciasRepositoryProvider)
        .moderarEditar(
          idClientePublicacionCondolencia:
              condolencia.idClientePublicacionCondolencia,
          texto: nuevoTexto,
        );
    await _refrescar();
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
          if (widget.esDueno) ...[
            ExportarCondolenciasButton(
              idClientePublicacion: widget.idClientePublicacion,
              nombreFallecido: widget.nombreFallecido,
            ),
            const SizedBox(height: 20),
          ],
          miCondolenciaAsync.when(
            data: (propia) {
              if (!_cargado) {
                _cargado = true;
                _textoController.text = propia?.texto ?? '';
                _anonima = propia?.anonima ?? false;
                _privada = propia?.privada ?? false;
              }
              return _MiCondolencia(
                propia: propia,
                editando: _editando,
                guardando: _guardando,
                controller: _textoController,
                anonima: _anonima,
                privada: _privada,
                onAnonimaChanged: (v) => setState(() => _anonima = v),
                onPrivadaChanged: (v) => setState(() => _privada = v),
                onEditar: () => setState(() => _editando = true),
                onCancelar: () => setState(() {
                  _editando = false;
                  _textoController.text = propia?.texto ?? '';
                  _anonima = propia?.anonima ?? false;
                  _privada = propia?.privada ?? false;
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
            esDueno: widget.esDueno,
            onModerarEliminar: _moderarEliminar,
            onModerarEditar: _moderarEditar,
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
  final bool anonima;
  final bool privada;
  final ValueChanged<bool> onAnonimaChanged;
  final ValueChanged<bool> onPrivadaChanged;
  final VoidCallback onEditar;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;
  final VoidCallback? onEliminar;

  const _MiCondolencia({
    required this.propia,
    required this.editando,
    required this.guardando,
    required this.controller,
    required this.anonima,
    required this.privada,
    required this.onAnonimaChanged,
    required this.onPrivadaChanged,
    required this.onEditar,
    required this.onCancelar,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (propia != null && propia!.moderadaOculta) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _AvisoModeracion(
            texto: context.l10n.condolenciasAvisoEliminada,
          ),
        ),
      );
    }
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
            if (!mostrarFormulario && propia!.moderadaEditada) ...[
              const SizedBox(height: 8),
              _AvisoModeracion(texto: context.l10n.condolenciasAvisoEditada),
            ],
            const SizedBox(height: 8),
            if (mostrarFormulario) ...[
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.condolenciasEscribeAqui,
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: anonima,
                onChanged: (v) => onAnonimaChanged(v ?? false),
                title: Text(context.l10n.condolenciasAnonimaTitulo),
                subtitle: Text(context.l10n.condolenciasAnonimaAyuda),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: privada,
                onChanged: (v) => onPrivadaChanged(v ?? false),
                title: Text(context.l10n.condolenciasPrivadaTitulo),
                subtitle: Text(context.l10n.condolenciasPrivadaAyuda),
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
              if (propia!.anonima || propia!.privada) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (propia!.anonima)
                      Chip(label: Text(context.l10n.condolenciasAnonimaTitulo)),
                    if (propia!.privada)
                      Chip(label: Text(context.l10n.condolenciasPrivadaTitulo)),
                  ],
                ),
              ],
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

/// Aviso de que el cliente dueño de la esquela ha eliminado o editado una condolencia por
/// moderación: solo lo ve el propio autor, en su sección "Tu condolencia".
class _AvisoModeracion extends StatelessWidget {
  final String texto;
  const _AvisoModeracion({required this.texto});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onErrorContainer;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}

class _ListaCondolencias extends StatelessWidget {
  final PaginaResultado<Condolencia> resultado;
  final String? idMiCondolencia;
  final bool esDueno;
  final ValueChanged<Condolencia> onModerarEliminar;
  final ValueChanged<Condolencia> onModerarEditar;
  final VoidCallback onCargarMas;

  const _ListaCondolencias({
    required this.resultado,
    required this.idMiCondolencia,
    required this.esDueno,
    required this.onModerarEliminar,
    required this.onModerarEditar,
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
                  condolencia.nombreAutor ?? context.l10n.condolenciasAnonimo,
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
                // Moderación: solo el dueño de la esquela puede editar/retirar condolencias
                // ajenas (ver 050_moderacion_condolencias.sql).
                if (esDueno) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: context.l10n.editar,
                        onPressed: () => onModerarEditar(condolencia),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: context.l10n.eliminar,
                        onPressed: () => onModerarEliminar(condolencia),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
