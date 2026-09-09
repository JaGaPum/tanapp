import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/text_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/cruz_icon.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/sede_sin_renombrar_bloqueo.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../sesiones/application/sesiones_providers.dart';
import '../../../importacion_web/application/importacion_web_providers.dart';
import '../../../propuestas_publicaciones/application/propuestas_providers.dart';
import '../../../propuestas_publicaciones/data/propuestas_repository.dart';
import '../../application/publicaciones_providers.dart';
import '../../data/publicaciones_repository.dart';

String _formatearHora(TimeOfDay hora) =>
    '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

/// Valor sintético del desplegable de tipo de acto para "Otro" (no es un id real del catálogo):
/// al elegirlo se muestra el campo de texto libre "ActoTipoOtro" en vez de un id de catálogo.
const _actoTipoOtroSentinel = '__otro__';

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
  final String? idClientePublicacionProgramada;
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
  final String? idClientePublicacionPropuestaInicial;

  /// Solo si se abre para editar una publicación programada existente
  /// ([idClientePublicacionProgramada] no nulo): la fecha/hora con la que se creó.
  final DateTime? fechaProgramadaInicial;

  /// 'ESQUELA' (por defecto) o 'ACTO' (misa u otro acto de recuerdo — ver 064): fijo durante toda
  /// la vida de esta pantalla, decidido por la tarjeta pulsada en Publicar (alta) o por el tipo
  /// que ya tenía la publicación que se está editando, nunca elegible dentro del propio formulario.
  final String tipoInicial;
  final String? idConfiguracionActoTipoInicial;
  final String? actoTipoOtroInicial;

  /// Solo para esquelas (069): si admite condolencias, y si estas han de ser todas privadas. Un
  /// acto nunca las admite, tenga lo que tenga esto (ver [_esActo]), así que no hace falta
  /// preguntarlo en ese caso.
  final bool admiteCondolenciasInicial;
  final bool condolenciasSoloPrivadasInicial;

  const PublicacionFormScreen({
    super.key,
    this.idClientePublicacion,
    this.idClientePublicacionProgramada,
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
    this.idClientePublicacionPropuestaInicial,
    this.fechaProgramadaInicial,
    this.tipoInicial = 'ESQUELA',
    this.idConfiguracionActoTipoInicial,
    this.actoTipoOtroInicial,
    this.admiteCondolenciasInicial = true,
    this.condolenciasSoloPrivadasInicial = false,
  });

  @override
  ConsumerState<PublicacionFormScreen> createState() =>
      _PublicacionFormScreenState();
}

class _PublicacionFormScreenState extends ConsumerState<PublicacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(
    text: widget.nombreInicial ?? '',
  );
  late final _edadController = TextEditingController(
    text: widget.edadInicial?.toString() ?? '',
  );
  late final _iglesiaController = TextEditingController(
    text: widget.iglesiaInicial ?? '',
  );
  late final _lugarController = TextEditingController(
    text: widget.lugarInicial ?? '',
  );
  late final _capillaArdienteController = TextEditingController(
    text: widget.capillaArdienteInicial ?? '',
  );
  late final _salaController = TextEditingController(
    text: widget.salaInicial ?? '',
  );
  late final _observacionesController = TextEditingController(
    text: widget.observacionesInicial ?? '',
  );
  late final _actoTipoOtroController = TextEditingController(
    text: widget.actoTipoOtroInicial ?? '',
  );
  late String? _actoTipoSeleccionado =
      widget.idConfiguracionActoTipoInicial ??
      (widget.actoTipoOtroInicial != null &&
              widget.actoTipoOtroInicial!.isNotEmpty
          ? _actoTipoOtroSentinel
          : null);
  late DateTime? _fechaFallecimiento = widget.fechaFallecimientoInicial;
  late DateTime? _fechaFuneral = widget.fechaFuneralInicial;
  late TimeOfDay? _horaFuneral = _parsearHora(widget.horaFuneralInicial);
  late String? _idClienteSedeSeleccionada = widget.idClienteSedeInicial;
  late bool _programar = widget.fechaProgramadaInicial != null;
  late DateTime? _fechaProgramada = widget.fechaProgramadaInicial;
  late TimeOfDay? _horaProgramada = widget.fechaProgramadaInicial == null
      ? null
      : TimeOfDay(
          hour: widget.fechaProgramadaInicial!.hour,
          minute: widget.fechaProgramadaInicial!.minute,
        );
  late bool _admiteCondolencias = widget.admiteCondolenciasInicial;
  late bool _condolenciasSoloPrivadas = widget.condolenciasSoloPrivadasInicial;
  bool _intentoEnviar = false;
  bool _loading = false;
  String? _error;

  bool get _esEdicion => widget.idClientePublicacion != null;
  bool get _editandoProgramada => widget.idClientePublicacionProgramada != null;
  bool get _esActo => widget.tipoInicial == 'ACTO';

  /// Un acto civil (no religioso) no lleva iglesia: se oculta el campo entero en vez de solo
  /// dejarlo vacío, para no dar a entender que hace falta rellenarlo. Con el catálogo aún sin
  /// cargar, sin nada elegido todavía, o con "Otro" seleccionado, se deja visible por defecto
  /// (no se puede saber de antemano si es religioso o no).
  bool get _mostrarIglesia {
    if (!_esActo) return true;
    if (_actoTipoSeleccionado == null ||
        _actoTipoSeleccionado == _actoTipoOtroSentinel) {
      return true;
    }
    final nombre = ref
        .read(actoTiposListProvider)
        .maybeWhen(data: (tipos) => tipos, orElse: () => const [])
        .where((t) => t.idConfiguracionActoTipo == _actoTipoSeleccionado)
        .map((t) => t.nombre)
        .firstOrNull;
    return nombre == null || nombre.toLowerCase().contains('misa');
  }

  @override
  void initState() {
    super.initState();
    final aviso = widget.avisoInicial;
    if (aviso != null && aviso.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(aviso)));
        }
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
    _actoTipoOtroController.dispose();
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
      // Un acto (misa de cabo de ano, aniversario...) se suele planificar con mucha más
      // antelación que un funeral: se le da bastante más margen hacia adelante.
      lastDate: DateTime(DateTime.now().year + (_esActo ? 5 : 1)),
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

  Future<void> _confirmarYPublicar() async {
    setState(() => _intentoEnviar = true);
    final formValido = _formKey.currentState!.validate();
    // Un acto (misa u otro, 064) no exige fecha de fallecimiento -puede ser mucho más tarde, o ni
    // conocerse aquí-, pero sí fecha/hora del propio acto, igual que una esquela con su funeral.
    final fechasCompletas = _esActo
        ? (_fechaFuneral != null && _horaFuneral != null)
        : (_fechaFallecimiento != null &&
              _fechaFuneral != null &&
              _horaFuneral != null);
    final programadaCompleta =
        !_programar || (_fechaProgramada != null && _horaProgramada != null);
    final tipoActoCompleto =
        !_esActo ||
        (_actoTipoSeleccionado != null &&
            (_actoTipoSeleccionado != _actoTipoOtroSentinel ||
                _actoTipoOtroController.text.trim().isNotEmpty));
    if (!formValido ||
        !fechasCompletas ||
        !programadaCompleta ||
        !tipoActoCompleto) {
      return;
    }
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

    final nombre = formatearTitulo(_nombreController.text);
    final iglesia = _mostrarIglesia
        ? formatearTitulo(_iglesiaController.text)
        : '';
    final lugar = formatearTitulo(_lugarController.text);
    final capillaArdiente = formatearTitulo(_capillaArdienteController.text);
    final sala = formatearTitulo(_salaController.text);
    final observaciones = _observacionesController.text.trim();
    final edad = int.tryParse(_edadController.text.trim());
    final horaFuneral = _formatearHora(_horaFuneral!);
    final esOtroActoTipo = _actoTipoSeleccionado == _actoTipoOtroSentinel;
    final idConfiguracionActoTipo = _esActo && !esOtroActoTipo
        ? _actoTipoSeleccionado
        : null;
    final actoTipoOtro = _esActo && esOtroActoTipo
        ? _actoTipoOtroController.text.trim()
        : null;
    final nombreActoTipo = _esActo
        ? (actoTipoOtro ??
              ref
                  .read(actoTiposListProvider)
                  .maybeWhen(
                    data: (tipos) => tipos
                        .where(
                          (t) =>
                              t.idConfiguracionActoTipo ==
                              idConfiguracionActoTipo,
                        )
                        .map((t) => t.nombre)
                        .firstOrNull,
                    orElse: () => null,
                  ))
        : null;

    final confirmado = await _mostrarVistaPrevia(
      nombre: nombre,
      edad: edad,
      iglesia: iglesia,
      lugar: lugar,
      capillaArdiente: capillaArdiente,
      sala: sala,
      observaciones: observaciones,
      nombreActoTipo: nombreActoTipo,
    );
    if (confirmado != true || !mounted) return;

    // Un acto nunca admite condolencias (069): no tiene sentido preguntarlo. En edición se
    // pregunta igual, pero con lo que ya tenía configurado como valor de partida, para que el
    // cliente pueda cambiarlo si quiere en vez de tener que fijarlo para siempre al publicar.
    if (!_esActo) {
      final continuar = await _preguntarCondolencias();
      if (!continuar || !mounted) return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final mensaje = _esEdicion
        ? context.l10n.publicarCambiosGuardados
        : _editandoProgramada
        ? context.l10n.publicarProgramacionActualizada
        : _programar
        ? context.l10n.publicarProgramadaOk
        : context.l10n.publicarPublicadoOk;
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
          tipo: widget.tipoInicial,
          idConfiguracionActoTipo: idConfiguracionActoTipo,
          actoTipoOtro: actoTipoOtro,
          admiteCondolencias: _admiteCondolencias,
          condolenciasSoloPrivadas: _condolenciasSoloPrivadas,
        );
      } else if (_editandoProgramada) {
        await repo.actualizarPublicacionProgramada(
          idClientePublicacionProgramada:
              widget.idClientePublicacionProgramada!,
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
          fechaProgramada: fechaProgramadaCompleta!,
          tipo: widget.tipoInicial,
          idConfiguracionActoTipo: idConfiguracionActoTipo,
          actoTipoOtro: actoTipoOtro,
          admiteCondolencias: _admiteCondolencias,
          condolenciasSoloPrivadas: _condolenciasSoloPrivadas,
        );
      } else if (_programar) {
        await repo.crearPublicacionProgramada(
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
          fechaProgramada: fechaProgramadaCompleta!,
          tipo: widget.tipoInicial,
          idConfiguracionActoTipo: idConfiguracionActoTipo,
          actoTipoOtro: actoTipoOtro,
          admiteCondolencias: _admiteCondolencias,
          condolenciasSoloPrivadas: _condolenciasSoloPrivadas,
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
          tipo: widget.tipoInicial,
          idConfiguracionActoTipo: idConfiguracionActoTipo,
          actoTipoOtro: actoTipoOtro,
          admiteCondolencias: _admiteCondolencias,
          condolenciasSoloPrivadas: _condolenciasSoloPrivadas,
        );
      }
      if (!_esEdicion && !_editandoProgramada) {
        final idPropuesta = widget.idClientePublicacionPropuestaInicial;
        if (idPropuesta != null) {
          await ref
              .read(propuestasRepositoryProvider)
              .marcarPublicada(idPropuesta);
          ref.invalidate(propuestasPendientesProvider);
        }
      }
      ref.invalidate(misPublicacionesProvider);
      ref.invalidate(publicacionesTablonProvider);
      ref.invalidate(publicacionesPorSedeProvider(_idClienteSedeSeleccionada!));
      ref.invalidate(misPublicacionesProgramadasProvider);
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

  Future<bool?> _mostrarVistaPrevia({
    required String nombre,
    required int? edad,
    required String iglesia,
    required String lugar,
    required String capillaArdiente,
    required String sala,
    required String observaciones,
    required String? nombreActoTipo,
  }) {
    final filas = <Widget>[
      if (nombreActoTipo != null)
        _FilaVistaPrevia(icon: Icons.category_outlined, texto: nombreActoTipo),
      if (_fechaFallecimiento != null || edad != null)
        _FilaVistaPrevia(
          icon: Icons.event_outlined,
          texto: [
            if (_fechaFallecimiento != null)
              context.l10n.publicarFallecioEl(
                DateFormat('dd/MM/yyyy').format(_fechaFallecimiento!),
              ),
            if (edad != null) context.l10n.publicarAnosDeEdad(edad),
          ].join(' · '),
        ),
      if (capillaArdiente.isNotEmpty)
        _FilaVistaPrevia(
          icon: Icons.local_florist_outlined,
          texto: capillaArdiente,
        ),
      if (sala.isNotEmpty)
        _FilaVistaPrevia(
          icon: Icons.meeting_room_outlined,
          texto: '${context.l10n.publicarSala} $sala',
        ),
      if (_fechaFuneral != null)
        _FilaVistaPrevia(
          icon: Icons.event_outlined,
          texto: DateFormat('dd/MM/yyyy').format(_fechaFuneral!),
        ),
      if (_horaFuneral != null)
        _FilaVistaPrevia(
          icon: Icons.schedule,
          texto: _formatearHora(_horaFuneral!),
        ),
      if (iglesia.isNotEmpty)
        _FilaVistaPrevia(icon: Icons.church_outlined, texto: iglesia),
      if (lugar.isNotEmpty)
        _FilaVistaPrevia(icon: Icons.place_outlined, texto: lugar),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _esActo
                      ? Icon(
                          _mostrarIglesia
                              ? Icons.church_outlined
                              : Icons.groups_outlined,
                          size: 20,
                        )
                      : const CruzIcon(size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
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
            child: Text(
              _esEdicion || _editandoProgramada
                  ? context.l10n.guardar
                  : _programar
                  ? context.l10n.publicarProgramar
                  : context.l10n.publicarPublicar,
            ),
          ),
        ],
      ),
    );
  }

  /// Tras confirmar la vista previa de una esquela (nunca para un acto, ver [_esActo]), pregunta
  /// si admite condolencias y, de admitirlas, si han de ser todas privadas — antes de publicar de
  /// verdad. Devuelve false si se cancela, en cuyo caso no se debe seguir con la publicación.
  Future<bool> _preguntarCondolencias() async {
    var admite = _admiteCondolencias;
    var soloPrivadas = _condolenciasSoloPrivadas;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(context.l10n.publicarCondolenciasPreguntaTitulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.publicarAdmiteCondolencias),
                subtitle: Text(context.l10n.publicarAdmiteCondolenciasAyuda),
                value: admite,
                onChanged: (value) => setStateDialog(() {
                  admite = value;
                  if (!value) soloPrivadas = false;
                }),
              ),
              if (admite)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.publicarCondolenciasPrivadas),
                  subtitle: Text(
                    context.l10n.publicarCondolenciasPrivadasAyuda,
                  ),
                  value: soloPrivadas,
                  onChanged: (value) =>
                      setStateDialog(() => soloPrivadas = value),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.confirmDialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.publicarCondolenciasContinuar),
            ),
          ],
        ),
      ),
    );
    if (confirmado != true) return false;
    setState(() {
      _admiteCondolencias = admite;
      _condolenciasSoloPrivadas = soloPrivadas;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final sedesAsync = ref.watch(misSedesProvider);
    final propuestasPendientes = ref.watch(propuestasPendientesCountProvider);
    final importacionWebConfigurada = ref
        .watch(miImportacionWebProvider)
        .maybeWhen(data: (config) => config != null, orElse: () => false);
    final importacionWebIaActiva = ref
        .watch(importacionWebIaActivaProvider)
        .maybeWhen(data: (activa) => activa, orElse: () => false);
    // Se lee aquí (en vez de solo dentro del getter) para que el "watch" haga que este build()
    // se reconstruya al cargar el catálogo o cambiar de tipo; el getter de abajo reutiliza el
    // mismo resultado ya cacheado por Riverpod sin volver a suscribirse.
    ref.watch(actoTiposListProvider);
    final mostrarIglesia = _mostrarIglesia;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion
              ? (_esActo
                    ? context.l10n.publicarEditarActo
                    : context.l10n.publicarEditarPublicacion)
              : _editandoProgramada
              ? context.l10n.publicarEditarProgramada
              : (_esActo
                    ? context.l10n.publicarNuevoActo
                    : context.l10n.publicarNuevaPublicacion),
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
          // Solo bloquea el alta de publicaciones nuevas; editar una ya existente (p. ej. para
          // corregir un dato) no depende de si la sede está bien nombrada.
          if (!_esEdicion && ref.watch(tieneSedeSinRenombrarProvider)) {
            return const SedeSinRenombrarBloqueo();
          }
          // Si no se ha pasado una sede explícita (p. ej. desde una propuesta de importación),
          // se propone la que tiene asignada esta sesión — sigue siendo un simple valor por
          // defecto, el desplegable de abajo permite cambiarla igualmente.
          _idClienteSedeSeleccionada ??=
              ref.read(sesionActualProvider).value?.idClienteSede ??
              sedes.first.idClienteSede;
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
                  // Escanear/importar web/propuestas son solo para esquelas (leen el formato de
                  // una esquela real): no tienen sentido al dar de alta un acto.
                  if (!_esActo && !_esEdicion && !_editandoProgramada) ...[
                    _EscanearBanner(
                      onTap: _loading
                          ? null
                          : () => context.pushReplacement('/publicar/escanear'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (sedes.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _idClienteSedeSeleccionada,
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarSeleccionaSede,
                        filled: true,
                        fillColor: AppColors.greenLight.withValues(alpha: 0.35),
                        // UnderlineInputBorder en vez de OutlineInputBorder: con este último,
                        // aunque el borde sea invisible ("BorderSide.none"), Flutter sigue
                        // colocando la etiqueta a caballo del borde (mitad dentro, mitad fuera de
                        // la caja) porque así es como se dibuja un campo "outline" -pensado para
                        // que la línea del borde se "corte" ahí-; al no haber línea visible que lo
                        // justifique, se veía como si la etiqueta estuviera montada encima del
                        // combo en vez de flotando dentro de él.
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: UnderlineInputBorder(
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
                  if (!_esEdicion) ...[
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
                            onChanged: _editandoProgramada
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
                                          labelText: context
                                              .l10n
                                              .publicarProgramarFecha,
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
                                          labelText: context
                                              .l10n
                                              .publicarProgramarHora,
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
                                              ? _formatearHora(_horaProgramada!)
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
                    label: _esActo
                        ? context.l10n.publicarEnMemoriaDe
                        : context.l10n.publicarNombreFallecido,
                    validator: Validators.required(
                      context,
                      _esActo
                          ? context.l10n.publicarEnMemoriaDe
                          : context.l10n.publicarNombreFallecido,
                    ),
                  ),
                  // Separado de los avisos de arriba (protección de datos) a propósito, para que
                  // no queden pegados el uno al otro: primero el nombre, luego el tipo de acto.
                  if (_esActo) ...[
                    const SizedBox(height: 16),
                    _TipoActoField(
                      seleccionado: _actoTipoSeleccionado,
                      intentoEnviar: _intentoEnviar,
                      onChanged: (value) =>
                          setState(() => _actoTipoSeleccionado = value),
                    ),
                    if (_actoTipoSeleccionado == _actoTipoOtroSentinel) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _actoTipoOtroController,
                        label: context.l10n.publicarTipoActoOtro,
                        validator: Validators.required(
                          context,
                          context.l10n.publicarTipoActoOtro,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirFechaFallecimiento,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.publicarFechaFallecimiento,
                        errorText:
                            _intentoEnviar &&
                                !_esActo &&
                                _fechaFallecimiento == null
                            ? context.l10n.validatorRequiredField(
                                context.l10n.publicarFechaFallecimiento,
                              )
                            : null,
                      ),
                      child: Text(
                        _fechaFallecimiento != null
                            ? DateFormat(
                                'dd/MM/yyyy',
                              ).format(_fechaFallecimiento!)
                            : '',
                      ),
                    ),
                  ),
                  // Edad no aporta nada en un acto (misa u otro): solo tiene sentido para la
                  // esquela del propio fallecimiento.
                  if (!_esActo) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _edadController,
                      label: context.l10n.publicarEdad,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.validatorRequiredField(
                            context.l10n.publicarEdad,
                          );
                        }
                        return int.tryParse(value.trim()) == null
                            ? context.l10n.publicarEdadInvalida
                            : null;
                      },
                    ),
                  ],
                  // Capilla ardiente y sala son del velatorio: no existen en un acto que no es un
                  // fallecimiento recién ocurrido.
                  if (!_esActo) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _capillaArdienteController,
                      label: context.l10n.publicarCapillaArdiente,
                      validator: Validators.required(
                        context,
                        context.l10n.publicarCapillaArdiente,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _salaController,
                      label: context.l10n.publicarSala,
                      validator: Validators.required(
                        context,
                        context.l10n.publicarSala,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirFechaFuneral,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _esActo
                            ? context.l10n.publicarFechaActo
                            : context.l10n.publicarFechaFuneral,
                        errorText: _intentoEnviar && _fechaFuneral == null
                            ? context.l10n.validatorRequiredField(
                                _esActo
                                    ? context.l10n.publicarFechaActo
                                    : context.l10n.publicarFechaFuneral,
                              )
                            : null,
                      ),
                      child: Text(
                        _fechaFuneral != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaFuneral!)
                            : '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _elegirHoraFuneral,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _esActo
                            ? context.l10n.publicarHoraActo
                            : context.l10n.publicarHoraFuneral,
                        errorText: _intentoEnviar && _horaFuneral == null
                            ? context.l10n.validatorRequiredField(
                                _esActo
                                    ? context.l10n.publicarHoraActo
                                    : context.l10n.publicarHoraFuneral,
                              )
                            : null,
                      ),
                      child: Text(
                        _horaFuneral != null
                            ? _formatearHora(_horaFuneral!)
                            : '',
                      ),
                    ),
                  ),
                  if (mostrarIglesia) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _iglesiaController,
                      label: _esActo
                          ? context.l10n.publicarIglesiaLocalizacion
                          : context.l10n.publicarIglesia,
                      // Un acto no religioso no tiene iglesia; en la esquela sigue siendo
                      // obligatoria, como siempre.
                      validator: _esActo
                          ? null
                          : Validators.required(
                              context,
                              context.l10n.publicarIglesia,
                            ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lugarController,
                    label: context.l10n.publicarLugar,
                    validator: Validators.required(
                      context,
                      context.l10n.publicarLugar,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _observacionesController,
                    label: context.l10n.publicarObservaciones,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _esEdicion || _editandoProgramada
                        ? context.l10n.guardar
                        : _programar
                        ? context.l10n.publicarProgramar
                        : context.l10n.publicarPublicar,
                    loading: _loading,
                    onPressed: _confirmarYPublicar,
                  ),
                  if (!_esActo && !_esEdicion && !_editandoProgramada) ...[
                    if (importacionWebIaActiva) ...[
                      const SizedBox(height: 12),
                      if (!importacionWebConfigurada)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.travel_explore),
                          label: Text(context.l10n.publicarImportarWeb),
                          onPressed: _loading
                              ? null
                              : () => context.pushReplacement(
                                  '/publicar/importar-web',
                                ),
                        )
                      else
                        OutlinedButton.icon(
                          icon: Badge(
                            isLabelVisible: propuestasPendientes > 0,
                            label: Text('$propuestasPendientes'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            child: const Icon(Icons.fact_check_outlined),
                          ),
                          label: Text(context.l10n.publicarPropuestas),
                          onPressed: _loading
                              ? null
                              : () => context.pushReplacement(
                                  '/publicar/propuestas',
                                ),
                        ),
                    ],
                  ],
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

/// Desplegable del tipo de acto (misa de cabo de ano, aniversario...), del catálogo editable por
/// el ADMIN (064) más una opción "Otro" que revela un campo de texto libre en el formulario.
class _TipoActoField extends ConsumerWidget {
  final String? seleccionado;
  final bool intentoEnviar;
  final ValueChanged<String?> onChanged;

  const _TipoActoField({
    required this.seleccionado,
    required this.intentoEnviar,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actoTiposAsync = ref.watch(actoTiposListProvider);
    return actoTiposAsync.when(
      data: (actoTipos) => DropdownButtonFormField<String>(
        initialValue: seleccionado,
        decoration: InputDecoration(
          labelText: context.l10n.publicarTipoActo,
          errorText: intentoEnviar && seleccionado == null
              ? context.l10n.validatorRequiredField(
                  context.l10n.publicarTipoActo,
                )
              : null,
        ),
        items: [
          for (final actoTipo in actoTipos)
            DropdownMenuItem(
              value: actoTipo.idConfiguracionActoTipo,
              child: Text(actoTipo.nombre),
            ),
          DropdownMenuItem(
            value: _actoTipoOtroSentinel,
            child: Text(context.l10n.publicarTipoActoOtroOpcion),
          ),
        ],
        onChanged: onChanged,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(context.l10n.errorGenerico(e.toString())),
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
          Icon(icon, size: 20, color: AppColors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: const TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

/// Banner destacado arriba del formulario manual: para que quien entra a publicar vea de
/// entrada que puede escanear la esquela en vez de rellenar todo a mano, en vez de tener que
/// llegar hasta el final del formulario para descubrirlo.
class _EscanearBanner extends StatelessWidget {
  final VoidCallback? onTap;
  const _EscanearBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.publicarEscanear,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.publicarEscanearAyuda,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.white),
            ],
          ),
        ),
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
