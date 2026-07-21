import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/text_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicaciones_repository.dart';

String _formatearHora(TimeOfDay hora) =>
    '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

TimeOfDay? _parsearHora(String? valor) {
  if (valor == null) return null;
  final partes = valor.split(':');
  if (partes.length < 2) return null;
  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);
  if (hora == null || minuto == null) return null;
  return TimeOfDay(hour: hora, minute: minuto);
}

/// Formulario de alta o edición de una publicación (esquela). En alta lo usan tanto "Manual"
/// (campos vacíos) como "Escanear" (algunos campos prellenados con lo que ha leído el OCR, para
/// revisar antes de publicar); en edición ([idClientePublicacion] no nulo) lo abre
/// "Publicacións" sobre una ya existente.
class PublicacionFormScreen extends ConsumerStatefulWidget {
  final String? idClientePublicacion;
  final String? idClienteSedeInicial;
  final String? nombreInicial;
  final DateTime? fechaFallecimientoInicial;
  final int? edadInicial;
  final DateTime? fechaFuneralInicial;
  final String? horaFuneralInicial;
  final String? iglesiaInicial;
  final String? lugarInicial;
  final String? capillaArdienteInicial;
  final String? salaInicial;
  final String? observacionesInicial;
  final String? avisoInicial;

  const PublicacionFormScreen({
    super.key,
    this.idClientePublicacion,
    this.idClienteSedeInicial,
    this.nombreInicial,
    this.fechaFallecimientoInicial,
    this.edadInicial,
    this.fechaFuneralInicial,
    this.horaFuneralInicial,
    this.iglesiaInicial,
    this.lugarInicial,
    this.capillaArdienteInicial,
    this.salaInicial,
    this.observacionesInicial,
    this.avisoInicial,
  });

  @override
  ConsumerState<PublicacionFormScreen> createState() => _PublicacionFormScreenState();
}

class _PublicacionFormScreenState extends ConsumerState<PublicacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(text: widget.nombreInicial ?? '');
  late final _edadController = TextEditingController(text: widget.edadInicial?.toString() ?? '');
  late final _iglesiaController = TextEditingController(text: widget.iglesiaInicial ?? '');
  late final _lugarController = TextEditingController(text: widget.lugarInicial ?? '');
  late final _capillaArdienteController = TextEditingController(text: widget.capillaArdienteInicial ?? '');
  late final _salaController = TextEditingController(text: widget.salaInicial ?? '');
  late final _observacionesController = TextEditingController(text: widget.observacionesInicial ?? '');
  late DateTime? _fechaFallecimiento = widget.fechaFallecimientoInicial;
  late DateTime? _fechaFuneral = widget.fechaFuneralInicial;
  late TimeOfDay? _horaFuneral = _parsearHora(widget.horaFuneralInicial);
  late String? _idClienteSedeSeleccionada = widget.idClienteSedeInicial;
  bool _intentoEnviar = false;
  bool _loading = false;
  String? _error;

  bool get _esEdicion => widget.idClientePublicacion != null;

  @override
  void initState() {
    super.initState();
    final aviso = widget.avisoInicial;
    if (aviso != null && aviso.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(aviso)));
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _iglesiaController.dispose();
    _lugarController.dispose();
    _capillaArdienteController.dispose();
    _salaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _elegirFechaFallecimiento() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaFallecimiento ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if (elegida != null) setState(() => _fechaFallecimiento = elegida);
  }

  Future<void> _elegirFechaFuneral() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaFuneral ?? _fechaFallecimiento ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (elegida != null) setState(() => _fechaFuneral = elegida);
  }

  Future<void> _elegirHoraFuneral() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _horaFuneral ?? TimeOfDay.now(),
    );
    if (elegida != null) setState(() => _horaFuneral = elegida);
  }

  Future<void> _confirmarYPublicar() async {
    setState(() => _intentoEnviar = true);
    final formValido = _formKey.currentState!.validate();
    final fechasCompletas = _fechaFallecimiento != null && _fechaFuneral != null && _horaFuneral != null;
    if (!formValido || !fechasCompletas) return;
    if (_idClienteSedeSeleccionada == null) return;

    final nombre = formatearTitulo(_nombreController.text);
    final iglesia = formatearTitulo(_iglesiaController.text);
    final lugar = formatearTitulo(_lugarController.text);
    final capillaArdiente = formatearTitulo(_capillaArdienteController.text);
    final sala = formatearTitulo(_salaController.text);
    final observaciones = _observacionesController.text.trim();
    final edad = int.tryParse(_edadController.text.trim());
    final horaFuneral = _formatearHora(_horaFuneral!);

    final confirmado = await _mostrarVistaPrevia(
      nombre: nombre,
      edad: edad,
      iglesia: iglesia,
      lugar: lugar,
      capillaArdiente: capillaArdiente,
      sala: sala,
      observaciones: observaciones,
    );
    if (confirmado != true || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    final mensaje = _esEdicion ? context.l10n.publicarCambiosGuardados : context.l10n.publicarPublicadoOk;
    try {
      final repo = ref.read(publicacionesRepositoryProvider);
      if (_esEdicion) {
        await repo.actualizarPublicacion(
          idClientePublicacion: widget.idClientePublicacion!,
          idClienteSede: _idClienteSedeSeleccionada!,
          nombreFallecido: nombre,
          fechaFallecimiento: _fechaFallecimiento,
          edad: edad,
          fechaFuneral: _fechaFuneral,
          horaFuneral: horaFuneral,
          iglesia: iglesia,
          lugar: lugar,
          capillaArdiente: capillaArdiente,
          sala: sala,
          observaciones: observaciones,
        );
      } else {
        await repo.crearPublicacion(
          idClienteSede: _idClienteSedeSeleccionada!,
          nombreFallecido: nombre,
          fechaFallecimiento: _fechaFallecimiento,
          edad: edad,
          fechaFuneral: _fechaFuneral,
          horaFuneral: horaFuneral,
          iglesia: iglesia,
          lugar: lugar,
          capillaArdiente: capillaArdiente,
          sala: sala,
          observaciones: observaciones,
        );
      }
      ref.invalidate(misPublicacionesProvider);
      ref.invalidate(publicacionesTablonProvider);
      ref.invalidate(publicacionesPorSedeProvider(_idClienteSedeSeleccionada!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool?> _mostrarVistaPrevia({
    required String nombre,
    required int? edad,
    required String iglesia,
    required String lugar,
    required String capillaArdiente,
    required String sala,
    required String observaciones,
  }) {
    final filas = <Widget>[
      if (_fechaFallecimiento != null || edad != null)
        _FilaVistaPrevia(
          icon: Icons.event_outlined,
          texto: [
            if (_fechaFallecimiento != null)
              context.l10n.publicarFallecioEl(DateFormat('dd/MM/yyyy').format(_fechaFallecimiento!)),
            if (edad != null) context.l10n.publicarAnosDeEdad(edad),
          ].join(' · '),
        ),
      if (_fechaFuneral != null)
        _FilaVistaPrevia(icon: Icons.event_outlined, texto: DateFormat('dd/MM/yyyy').format(_fechaFuneral!)),
      if (_horaFuneral != null)
        _FilaVistaPrevia(icon: Icons.schedule, texto: _formatearHora(_horaFuneral!)),
      if (iglesia.isNotEmpty) _FilaVistaPrevia(icon: Icons.church_outlined, texto: iglesia),
      if (lugar.isNotEmpty) _FilaVistaPrevia(icon: Icons.place_outlined, texto: lugar),
      if (capillaArdiente.isNotEmpty)
        _FilaVistaPrevia(icon: Icons.local_florist_outlined, texto: capillaArdiente),
      if (sala.isNotEmpty)
        _FilaVistaPrevia(icon: Icons.meeting_room_outlined, texto: '${context.l10n.publicarSala} $sala'),
    ];

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.publicarVistaPreviaTitulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✝ $nombre', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final fila in filas) ...[fila, const SizedBox(height: 4)],
              if (observaciones.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(observaciones),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.confirmDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_esEdicion ? context.l10n.guardar : context.l10n.publicarPublicar),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sedesAsync = ref.watch(misSedesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? context.l10n.publicarEditarPublicacion : context.l10n.publicarNuevaPublicacion),
      ),
      body: sedesAsync.when(
        data: (sedes) {
          if (sedes.isEmpty) {
            return EmptyState(message: context.l10n.publicarSinSedes, icon: Icons.storefront_outlined);
          }
          _idClienteSedeSeleccionada ??= sedes.first.idClienteSede;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ErrorBanner(message: _error!),
                  if (sedes.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _idClienteSedeSeleccionada,
                      decoration: InputDecoration(labelText: context.l10n.publicarSeleccionaSede),
                      items: sedes
                          .map(
                            (sede) => DropdownMenuItem(
                              value: sede.idClienteSede,
                              child: Text('${sede.codigo} · ${sede.nombre}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _idClienteSedeSeleccionada = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _AvisoBanner(
                    icon: Icons.fact_check_outlined,
                    texto: context.l10n.publicarAvisoRevisar,
                  ),
                  const SizedBox(height: 12),
                  _AvisoBanner(
                    icon: Icons.info_outline,
                    texto: context.l10n.publicarAvisoDatosPersonales,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _nombreController,
                    label: context.l10n.publicarNombreFallecido,
                    validator: Validators.required(context, context.l10n.publicarNombreFallecido),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirFechaFallecimiento,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarFechaFallecimiento,
                        errorText: _intentoEnviar && _fechaFallecimiento == null
                            ? context.l10n.validatorRequiredField(context.l10n.publicarFechaFallecimiento)
                            : null,
                      ),
                      child: Text(
                        _fechaFallecimiento != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaFallecimiento!)
                            : '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _edadController,
                    label: context.l10n.publicarEdad,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.validatorRequiredField(context.l10n.publicarEdad);
                      }
                      return int.tryParse(value.trim()) == null ? context.l10n.publicarEdadInvalida : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirFechaFuneral,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarFechaFuneral,
                        errorText: _intentoEnviar && _fechaFuneral == null
                            ? context.l10n.validatorRequiredField(context.l10n.publicarFechaFuneral)
                            : null,
                      ),
                      child: Text(_fechaFuneral != null ? DateFormat('dd/MM/yyyy').format(_fechaFuneral!) : ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirHoraFuneral,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarHoraFuneral,
                        errorText: _intentoEnviar && _horaFuneral == null
                            ? context.l10n.validatorRequiredField(context.l10n.publicarHoraFuneral)
                            : null,
                      ),
                      child: Text(_horaFuneral != null ? _formatearHora(_horaFuneral!) : ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _iglesiaController,
                    label: context.l10n.publicarIglesia,
                    validator: Validators.required(context, context.l10n.publicarIglesia),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lugarController,
                    label: context.l10n.publicarLugar,
                    validator: Validators.required(context, context.l10n.publicarLugar),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _capillaArdienteController,
                    label: context.l10n.publicarCapillaArdiente,
                    validator: Validators.required(context, context.l10n.publicarCapillaArdiente),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _salaController,
                    label: context.l10n.publicarSala,
                    validator: Validators.required(context, context.l10n.publicarSala),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _observacionesController,
                    label: context.l10n.publicarObservaciones,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _esEdicion ? context.l10n.guardar : context.l10n.publicarPublicar,
                    loading: _loading,
                    onPressed: _confirmarYPublicar,
                  ),
                  if (!_esEdicion) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: Text(context.l10n.publicarEscanear),
                      onPressed: _loading ? null : () => context.pushReplacement('/publicar/escanear'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _AvisoBanner extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _AvisoBanner({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _FilaVistaPrevia extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _FilaVistaPrevia({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(child: Text(texto)),
      ],
    );
  }
}
