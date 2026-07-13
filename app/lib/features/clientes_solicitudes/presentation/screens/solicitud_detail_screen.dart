import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../comunicaciones/data/comunicaciones_repository.dart';
import '../../application/solicitudes_providers.dart';
import '../../data/solicitud_cliente.dart';
import '../../data/solicitudes_repository.dart';

class SolicitudDetailScreen extends ConsumerStatefulWidget {
  final String idClientesSolicitud;
  const SolicitudDetailScreen({super.key, required this.idClientesSolicitud});

  @override
  ConsumerState<SolicitudDetailScreen> createState() => _SolicitudDetailScreenState();
}

class _SolicitudDetailScreenState extends ConsumerState<SolicitudDetailScreen> {
  final _observacionesController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _eliminar() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.solicitudEliminarTitulo,
      message: context.l10n.solicitudEliminarMensaje,
      confirmLabel: context.l10n.eliminar,
    );
    if (!confirmado) return;
    final solicitudesRepo = ref.read(solicitudesRepositoryProvider);
    try {
      await solicitudesRepo.eliminarSolicitud(widget.idClientesSolicitud);
      ref.invalidate(solicitudesListProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.solicitudNoSePudoEliminar);
    }
  }

  Future<void> _resolver(bool aprobar) async {
    final noIdentificadoMensaje = context.l10n.solicitudNoIdentificado;
    final confirmado = await showConfirmDialog(
      context,
      title: aprobar ? context.l10n.solicitudAprobarTitulo : context.l10n.solicitudRechazarTitulo,
      message: aprobar ? context.l10n.solicitudConfirmarAprobar : context.l10n.solicitudConfirmarRechazar,
      confirmLabel: aprobar ? context.l10n.aprobar : context.l10n.rechazar,
    );
    if (!confirmado) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      if (perfil == null) throw AppException(noIdentificadoMensaje);
      final solicitudesRepo = ref.read(solicitudesRepositoryProvider);
      await solicitudesRepo.resolver(
        id: widget.idClientesSolicitud,
        aprobar: aprobar,
        observacionesResolucion: _observacionesController.text,
        idSistemaUsuarioResolucion: perfil.idSistemaUsuario,
      );
      ref.invalidate(solicitudDetailProvider(widget.idClientesSolicitud));
      ref.invalidate(solicitudesListProvider);
      ref.invalidate(solicitudesPendientesCountProvider);

      final solicitud = await ref.read(solicitudDetailProvider(widget.idClientesSolicitud).future);
      await _notificarResolucion(aprobar: aprobar, solicitud: solicitud);

      if (aprobar) {
        try {
          await solicitudesRepo.crearUsuarioCliente(widget.idClientesSolicitud);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.solicitudAprobadaSinCuenta(_detalleError(e))),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _crearCuentaCliente() async {
    final cuentaCreadaMensaje = context.l10n.solicitudCuentaCreada;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(solicitudesRepositoryProvider).crearUsuarioCliente(widget.idClientesSolicitud);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cuentaCreadaMensaje)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.solicitudNoSePudoCrearCuenta(_detalleError(e)))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _detalleError(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      if (details is Map && details['error'] != null) return details['error'].toString();
      if (details is String && details.isNotEmpty) return details;
      return e.reasonPhrase ?? 'error ${e.status}';
    }
    return e.toString();
  }

  /// Sin SMTP configurado todavía: busca el texto de Configuración > Comunicaciones que
  /// correspondería enviar y lo deja preparado (solo log). Cuando haya SMTP, aquí se
  /// invocará la Edge Function real de envío con `comunicacion` y `solicitud.emailContacto`.
  Future<void> _notificarResolucion({required bool aprobar, required SolicitudCliente solicitud}) async {
    final codigo = aprobar ? 'SOLICITUD_APROBADA' : 'SOLICITUD_RECHAZADA';
    try {
      final comunicacion = await ref.read(comunicacionesRepositoryProvider).buscarPorCodigo(codigo);
      debugPrint(
        'TODO enviar "$codigo" a ${solicitud.emailContacto} '
        '(${comunicacion?.traducciones.length ?? 0} idiomas configurados) — pendiente de SMTP.',
      );
    } catch (e) {
      debugPrint('No se pudo preparar la notificación "$codigo": $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitudAsync = ref.watch(solicitudDetailProvider(widget.idClientesSolicitud));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.solicitudDetalleTitulo),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: context.l10n.eliminar, onPressed: _eliminar),
        ],
      ),
      body: solicitudAsync.when(
        data: (solicitud) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ErrorBanner(message: _error!),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(solicitud.razonSocial, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Chip(label: Text(_estadoLabel(context, solicitud.estado))),
                        const Divider(height: 32),
                        _Campo(label: context.l10n.fieldNifCif, valor: solicitud.nifCif),
                        _Campo(label: context.l10n.campoPersonaContacto, valor: solicitud.nombreContacto),
                        _Campo(label: context.l10n.fieldEmail, valor: solicitud.emailContacto),
                        _Campo(label: context.l10n.fieldTelefono, valor: solicitud.telefonoContacto),
                        if (solicitud.localidad != null)
                          _Campo(label: context.l10n.campoLocalidad, valor: solicitud.localidad!),
                        if (solicitud.provincia != null)
                          _Campo(label: context.l10n.fieldProvincia, valor: solicitud.provincia!),
                        if (solicitud.observaciones != null)
                          _Campo(label: context.l10n.campoObservaciones, valor: solicitud.observaciones!),
                      ],
                    ),
                  ),
                ),
                if (solicitud.estado == 'PENDIENTE') ...[
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _observacionesController,
                    label: context.l10n.fieldObservacionesResolucionOpcional,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: context.l10n.rechazar,
                          secondary: true,
                          loading: _loading,
                          onPressed: () => _resolver(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: context.l10n.aprobar,
                          loading: _loading,
                          onPressed: () => _resolver(true),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  if (solicitud.observacionesResolucion != null) ...[
                    const SizedBox(height: 16),
                    _Campo(
                      label: context.l10n.campoObservacionesResolucion,
                      valor: solicitud.observacionesResolucion!,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (solicitud.estado == 'APROBADA' && solicitud.tieneUsuarioCliente)
                    Chip(
                      avatar: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(context.l10n.solicitudCuentaCreada),
                    )
                  else if (solicitud.estado == 'APROBADA')
                    AppButton(
                      label: context.l10n.solicitudCrearCuentaBoton,
                      loading: _loading,
                      onPressed: _crearCuentaCliente,
                    )
                  else if (solicitud.estado == 'RECHAZADA')
                    AppButton(
                      label: context.l10n.solicitudAprobarBoton,
                      loading: _loading,
                      onPressed: () => _resolver(true),
                    ),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }

  String _estadoLabel(BuildContext context, String estado) => switch (estado) {
        'PENDIENTE' => context.l10n.pendiente,
        'APROBADA' => context.l10n.estadoAprobadaSingular,
        'RECHAZADA' => context.l10n.estadoRechazadaSingular,
        _ => estado,
      };
}

class _Campo extends StatelessWidget {
  final String label;
  final String valor;
  const _Campo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(valor, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
