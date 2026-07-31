import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../clientes_solicitudes/application/solicitudes_providers.dart';
import '../../application/avisos_providers.dart';
import '../../data/aviso_recibido.dart';
import '../../data/avisos_repository.dart';

class AvisosScreen extends ConsumerStatefulWidget {
  const AvisosScreen({super.key});

  @override
  ConsumerState<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends ConsumerState<AvisosScreen> {
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

  Future<void> _refrescarTrasBorrar() async {
    ref.invalidate(misAvisosRecibidosProvider);
    ref.invalidate(avisosNoLeidosCountProvider);
  }

  Future<void> _eliminarUno(AvisoRecibido aviso) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarMensaje(aviso.titulo),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref.read(avisosRepositoryProvider).eliminarAviso(aviso.idClienteAvisoDestinatario);
      await _refrescarTrasBorrar();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _eliminarSeleccionados() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.avisosEliminarTitulo,
      message: context.l10n.avisosEliminarSeleccionadosMensaje(_seleccionados.length),
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    setState(() => _procesando = true);
    try {
      await ref.read(avisosRepositoryProvider).eliminarAvisos(_seleccionados.toList());
      await _refrescarTrasBorrar();
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
      await ref.read(avisosRepositoryProvider).eliminarTodosAvisos();
      await _refrescarTrasBorrar();
      _cancelarSeleccion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    // Un ADMIN también puede seguir clientes como cualquier usuario ordinario, así que esta
    // pestaña le muestra las dos cosas: sus solicitudes de cliente pendientes de aprobar (si
    // las hay) Y su propia bandeja de avisos recibidos, no una cosa en vez de la otra.
    final pendientesSolicitudes = isAdmin ? ref.watch(solicitudesPendientesCountProvider).value ?? 0 : 0;
    final resultado = ref.watch(misAvisosRecibidosProvider);

    if (resultado.cargandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (resultado.error != null) {
      return Center(child: Text(context.l10n.errorGenerico(resultado.error.toString())));
    }
    if (pendientesSolicitudes == 0 && resultado.items.isEmpty) {
      return EmptyState(message: context.l10n.avisosVacioRecibidos, icon: Icons.notifications_outlined);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pendientesSolicitudes > 0) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_late_outlined, color: Colors.red),
                title: Text(context.l10n.avisoSolicitudesPendientes(pendientesSolicitudes)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/solicitudes'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (resultado.items.isNotEmpty) ...[
            if (_seleccionando)
              Row(
                children: [
                  Expanded(child: Text(context.l10n.avisosNSeleccionados(_seleccionados.length))),
                  TextButton(
                    onPressed: _procesando ? null : _cancelarSeleccion,
                    child: Text(context.l10n.avisosCancelarSeleccion),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.l10n.eliminar),
                    onPressed: _procesando || _seleccionados.isEmpty ? null : _eliminarSeleccionados,
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
              child: PaginatedListView<AvisoRecibido>(
                items: resultado.items,
                cargandoMas: resultado.cargandoMas,
                hasMore: resultado.hasMore,
                onCargarMas: () => ref.read(misAvisosRecibidosProvider.notifier).cargarMas(),
                itemBuilder: (context, aviso) => _AvisoRecibidoCard(
                  aviso: aviso,
                  seleccionando: _seleccionando,
                  seleccionado: _seleccionados.contains(aviso.idClienteAvisoDestinatario),
                  onIniciarSeleccion: () => _iniciarSeleccion(aviso.idClienteAvisoDestinatario),
                  onAlternarSeleccion: () => _alternarSeleccion(aviso.idClienteAvisoDestinatario),
                  onEliminar: () => _eliminarUno(aviso),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvisoRecibidoCard extends ConsumerWidget {
  final AvisoRecibido aviso;
  final bool seleccionando;
  final bool seleccionado;
  final VoidCallback onIniciarSeleccion;
  final VoidCallback onAlternarSeleccion;
  final VoidCallback onEliminar;

  const _AvisoRecibidoCard({
    required this.aviso,
    required this.seleccionando,
    required this.seleccionado,
    required this.onIniciarSeleccion,
    required this.onAlternarSeleccion,
    required this.onEliminar,
  });

  Future<void> _abrir(BuildContext context, WidgetRef ref) async {
    if (!aviso.leido) {
      await ref.read(avisosRepositoryProvider).marcarLeido(aviso.idClienteAvisoDestinatario);
      ref.invalidate(avisosNoLeidosCountProvider);
      ref.invalidate(misAvisosRecibidosProvider);
    }
    if (context.mounted) {
      showDialog<void>(context: context, builder: (_) => _AvisoDetailDialog(aviso: aviso));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: seleccionando
            ? Checkbox(value: seleccionado, onChanged: (_) => onAlternarSeleccion())
            : Icon(
                aviso.leido ? Icons.mail_outline : Icons.mark_email_unread,
                color: aviso.leido ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.primary,
              ),
        title: Text(
          aviso.titulo,
          style: TextStyle(fontWeight: aviso.leido ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Text(
          '${aviso.nombreCliente} · '
          '${DateFormat('dd/MM/yyyy HH:mm').format(aviso.fechaAlta.toLocal())}',
        ),
        trailing: seleccionando
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.l10n.eliminar,
                onPressed: onEliminar,
              ),
        onTap: seleccionando ? onAlternarSeleccion : () => _abrir(context, ref),
        onLongPress: seleccionando ? null : onIniciarSeleccion,
      ),
    );
  }
}

class _AvisoDetailDialog extends StatelessWidget {
  final AvisoRecibido aviso;
  const _AvisoDetailDialog({required this.aviso});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(aviso.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${aviso.nombreCliente} · ${aviso.nombreSede}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Text(aviso.texto),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.avisosCerrar),
        ),
      ],
    );
  }
}
