import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/sede_sin_renombrar_bloqueo.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../application/avisos_providers.dart';
import '../../data/avisos_repository.dart';

/// Formulario de alta de un aviso; en edición ([idClienteAvisoProgramado] no nulo) lo abre la
/// lista de "Programados" (055) sobre uno todavía pendiente de enviarse.
class AvisoFormScreen extends ConsumerStatefulWidget {
  final String? idClienteAvisoProgramado;
  final String? idClienteSedeInicial;
  final String? tituloInicial;
  final String? textoInicial;

  /// Solo si se abre para editar un aviso programado existente
  /// ([idClienteAvisoProgramado] no nulo): la fecha/hora con la que se creó.
  final DateTime? fechaProgramadaInicial;

  const AvisoFormScreen({
    super.key,
    this.idClienteAvisoProgramado,
    this.idClienteSedeInicial,
    this.tituloInicial,
    this.textoInicial,
    this.fechaProgramadaInicial,
  });

  @override
  ConsumerState<AvisoFormScreen> createState() => _AvisoFormScreenState();
}

class _AvisoFormScreenState extends ConsumerState<AvisoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _tituloController = TextEditingController(
    text: widget.tituloInicial ?? '',
  );
  late final _textoController = TextEditingController(
    text: widget.textoInicial ?? '',
  );
  late String? _idClienteSedeSeleccionada = widget.idClienteSedeInicial;
  late bool _programar = widget.fechaProgramadaInicial != null;
  late DateTime? _fechaProgramada = widget.fechaProgramadaInicial;
  late TimeOfDay? _horaProgramada = widget.fechaProgramadaInicial == null
      ? null
      : TimeOfDay(
          hour: widget.fechaProgramadaInicial!.hour,
          minute: widget.fechaProgramadaInicial!.minute,
        );
  bool _intentoEnviar = false;
  bool _loading = false;
  String? _error;

  bool get _editandoProgramado => widget.idClienteAvisoProgramado != null;

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFechaProgramada() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaProgramada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (elegida != null) setState(() => _fechaProgramada = elegida);
  }

  Future<void> _elegirHoraProgramada() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _horaProgramada ?? TimeOfDay.now(),
    );
    if (elegida != null) setState(() => _horaProgramada = elegida);
  }

  Future<void> _enviar() async {
    setState(() => _intentoEnviar = true);
    final formValido = _formKey.currentState!.validate();
    final programadaCompleta =
        !_programar || (_fechaProgramada != null && _horaProgramada != null);
    if (!formValido || !programadaCompleta) return;
    if (_idClienteSedeSeleccionada == null) return;

    DateTime? fechaProgramadaCompleta;
    if (_programar) {
      fechaProgramadaCompleta = DateTime(
        _fechaProgramada!.year,
        _fechaProgramada!.month,
        _fechaProgramada!.day,
        _horaProgramada!.hour,
        _horaProgramada!.minute,
      );
      if (fechaProgramadaCompleta.isBefore(DateTime.now())) {
        setState(() => _error = context.l10n.publicarProgramarEnElPasado);
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final mensaje = _editandoProgramado
        ? context.l10n.publicarProgramacionActualizada
        : _programar
        ? context.l10n.publicarProgramadaOk
        : context.l10n.avisosEnviadoOk;
    try {
      final repo = ref.read(avisosRepositoryProvider);
      if (_editandoProgramado) {
        await repo.actualizarAvisoProgramado(
          idClienteAvisoProgramado: widget.idClienteAvisoProgramado!,
          idClienteSede: _idClienteSedeSeleccionada!,
          titulo: _tituloController.text,
          texto: _textoController.text,
          fechaProgramada: fechaProgramadaCompleta!,
        );
      } else if (_programar) {
        await repo.crearAvisoProgramado(
          idClienteSede: _idClienteSedeSeleccionada!,
          titulo: _tituloController.text,
          texto: _textoController.text,
          fechaProgramada: fechaProgramadaCompleta!,
        );
      } else {
        await repo.crearAviso(
          idClienteSede: _idClienteSedeSeleccionada!,
          titulo: _tituloController.text,
          texto: _textoController.text,
        );
      }
      ref.invalidate(misAvisosEnviadosProvider);
      ref.invalidate(misAvisosProgramadosProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(
        () => _error = e is AppException
            ? e.message
            : context.l10n.errorInesperado,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedesAsync = ref.watch(misSedesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editandoProgramado
              ? context.l10n.avisosEditarProgramado
              : context.l10n.avisosFormTitulo,
        ),
      ),
      body: sedesAsync.when(
        data: (sedes) {
          if (sedes.isEmpty) {
            return EmptyState(
              message: context.l10n.publicarSinSedes,
              icon: Icons.storefront_outlined,
            );
          }
          if (ref.watch(tieneSedeSinRenombrarProvider)) {
            return const SedeSinRenombrarBloqueo();
          }
          _idClienteSedeSeleccionada ??= sedes.first.idClienteSede;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ErrorBanner(message: _error!),
                  if (sedes.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _idClienteSedeSeleccionada,
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarSeleccionaSede,
                        filled: true,
                        fillColor: AppColors.greenLight.withValues(alpha: 0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: sedes
                          .map(
                            (sede) => DropdownMenuItem(
                              value: sede.idClienteSede,
                              child: Text(
                                '${sede.codigo} · ${sede.nombre}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _idClienteSedeSeleccionada = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.publicarProgramarTitulo,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(context.l10n.publicarProgramarAyuda),
                          value: _programar,
                          onChanged: _editandoProgramado
                              ? null
                              : (value) => setState(() => _programar = value),
                        ),
                        if (_programar) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _elegirFechaProgramada,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText:
                                            context.l10n.publicarProgramarFecha,
                                        errorText:
                                            _intentoEnviar &&
                                                _fechaProgramada == null
                                            ? context.l10n
                                                  .validatorRequiredField(
                                                    context
                                                        .l10n
                                                        .publicarProgramarFecha,
                                                  )
                                            : null,
                                      ),
                                      child: Text(
                                        _fechaProgramada != null
                                            ? DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(_fechaProgramada!)
                                            : '',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _elegirHoraProgramada,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText:
                                            context.l10n.publicarProgramarHora,
                                        errorText:
                                            _intentoEnviar &&
                                                _horaProgramada == null
                                            ? context.l10n
                                                  .validatorRequiredField(
                                                    context
                                                        .l10n
                                                        .publicarProgramarHora,
                                                  )
                                            : null,
                                      ),
                                      child: Text(
                                        _horaProgramada != null
                                            ? '${_horaProgramada!.hour.toString().padLeft(2, '0')}:${_horaProgramada!.minute.toString().padLeft(2, '0')}'
                                            : '',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _tituloController,
                    label: context.l10n.avisosTituloLabel,
                    validator: Validators.required(
                      context,
                      context.l10n.avisosTituloLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _textoController,
                    label: context.l10n.avisosTextoLabel,
                    maxLines: 6,
                    validator: Validators.required(
                      context,
                      context.l10n.avisosTextoLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _editandoProgramado
                        ? context.l10n.guardar
                        : _programar
                        ? context.l10n.publicarProgramar
                        : context.l10n.avisosEnviar,
                    loading: _loading,
                    onPressed: _enviar,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
