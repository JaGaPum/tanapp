import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../application/avisos_providers.dart';
import '../../data/avisos_repository.dart';
import '../../data/cliente_aviso.dart';

class AvisosEnviadosScreen extends ConsumerStatefulWidget {
  const AvisosEnviadosScreen({super.key});

  @override
  ConsumerState<AvisosEnviadosScreen> createState() =>
      _AvisosEnviadosScreenState();
}

class _AvisosEnviadosScreenState extends ConsumerState<AvisosEnviadosScreen> {
  final _seleccionados = <String>{};
  bool _seleccionando = false;
  bool _procesando = false;

  void _iniciarSeleccion(String idInicial) {
    setState(() {
      _seleccionando = true;
      _seleccionados
        ..clear()
        ..add(idInicial);
    });
  }

  void _alternarSeleccion(String id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
  }

  void _cancelarSeleccion() {
    setState(() {
      _seleccionando = false;
      _seleccionados.clear();
    });
  }

  Future<void> _eliminarUno(ClienteAviso aviso) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarMensaje(aviso.titulo),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref
          .read(avisosRepositoryProvider)
          .eliminarAvisoEnviado(aviso.idClienteAviso);
      ref.invalidate(misAvisosEnviadosProvider);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _eliminarSeleccionados() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarSeleccionadosMensaje(
        _seleccionados.length,
      ),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref
          .read(avisosRepositoryProvider)
          .eliminarAvisosEnviados(_seleccionados.toList());
      ref.invalidate(misAvisosEnviadosProvider);
      _cancelarSeleccion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _vaciarTodo() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosVaciarTodoTitulo,
      message: context.l10n.avisosVaciarTodoMensaje,
      confirmLabel: context.l10n.avisosVaciarTodoTitulo,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      final sedes = await ref.read(misSedesProvider.future);
      await ref
          .read(avisosRepositoryProvider)
          .eliminarTodosAvisosEnviados(
            sedes.map((s) => s.idClienteSede).toList(),
          );
      ref.invalidate(misAvisosEnviadosProvider);
      _cancelarSeleccion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = ref.watch(misAvisosEnviadosProvider);

    if (resultado.cargandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (resultado.error != null) {
      return Center(
        child: Text(context.l10n.errorGenerico(resultado.error.toString())),
      );
    }
    if (resultado.items.isEmpty) {
      return EmptyState(
        message: context.l10n.avisosVacioEnviados,
        icon: Icons.campaign_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_seleccionando)
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.avisosNSeleccionados(_seleccionados.length),
                  ),
                ),
                TextButton(
                  onPressed: _procesando ? null : _cancelarSeleccion,
                  child: Text(context.l10n.avisosCancelarSeleccion),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.l10n.eliminar),
                  onPressed: _procesando || _seleccionados.isEmpty
                      ? null
                      : _eliminarSeleccionados,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(context.l10n.avisosVaciarTodoTitulo),
                  onPressed: _procesando ? null : _vaciarTodo,
                ),
              ],
            ),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<ClienteAviso>(
              items: resultado.items,
              cargandoMas: resultado.cargandoMas,
              hasMore: resultado.hasMore,
              onCargarMas: () =>
                  ref.read(misAvisosEnviadosProvider.notifier).cargarMas(),
              itemBuilder: (context, aviso) => _AvisoEnviadoCard(
                aviso: aviso,
                seleccionando: _seleccionando,
                seleccionado: _seleccionados.contains(aviso.idClienteAviso),
                onIniciarSeleccion: () =>
                    _iniciarSeleccion(aviso.idClienteAviso),
                onAlternarSeleccion: () =>
                    _alternarSeleccion(aviso.idClienteAviso),
                onEliminar: () => _eliminarUno(aviso),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoEnviadoCard extends StatelessWidget {
  final ClienteAviso aviso;
  final bool seleccionando;
  final bool seleccionado;
  final VoidCallback onIniciarSeleccion;
  final VoidCallback onAlternarSeleccion;
  final VoidCallback onEliminar;

  const _AvisoEnviadoCard({
    required this.aviso,
    required this.seleccionando,
    required this.seleccionado,
    required this.onIniciarSeleccion,
    required this.onAlternarSeleccion,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: seleccionando ? onAlternarSeleccion : null,
        onLongPress: seleccionando ? null : onIniciarSeleccion,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (seleccionando) ...[
                Checkbox(
                  value: seleccionado,
                  onChanged: (_) => onAlternarSeleccion(),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aviso.titulo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.avisosEnviadoEl(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(aviso.fechaAlta.toLocal()),
                        DateFormat('HH:mm').format(aviso.fechaAlta.toLocal()),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(aviso.texto),
                    if (aviso.nombreSede.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        aviso.nombreSede,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!seleccionando)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.l10n.eliminar,
                  onPressed: onEliminar,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
