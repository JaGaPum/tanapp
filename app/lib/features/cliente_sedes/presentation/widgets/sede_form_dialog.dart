import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/provincia_concello_fields.dart';
import '../../data/cliente_sede.dart';
import '../../data/cliente_sedes_repository.dart';

/// Formulario de alta/edición de una sede. [idSistemaUsuario] es el cliente dueño (al que se
/// le crea la sede si [sede] es null) — se pasa explícito en vez de leerlo del usuario
/// actualmente autenticado porque este diálogo también lo usa el ADMIN para gestionar sedes
/// de otro usuario, no solo el propio cliente en autoservicio.
class SedeFormDialog extends ConsumerStatefulWidget {
  final String idSistemaUsuario;
  final ClienteSede? sede;
  const SedeFormDialog({super.key, required this.idSistemaUsuario, this.sede});

  @override
  ConsumerState<SedeFormDialog> createState() => _SedeFormDialogState();
}

class _SedeFormDialogState extends ConsumerState<SedeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _codigoController = TextEditingController(text: widget.sede?.codigo ?? '');
  late final _nombreController = TextEditingController(text: widget.sede?.nombre ?? '');
  late final _direccionController = TextEditingController(text: widget.sede?.direccion ?? '');
  String? _provinciaSeleccionada;
  String? _concelloSeleccionado;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _provinciaSeleccionada = widget.sede?.provincia;
    _concelloSeleccionado = widget.sede?.concello;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_provinciaSeleccionada == null || _concelloSeleccionado == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(clienteSedesRepositoryProvider);
    try {
      if (widget.sede == null) {
        await repo.crearSede(
          idSistemaUsuario: widget.idSistemaUsuario,
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          provincia: _provinciaSeleccionada!,
          concello: _concelloSeleccionado!,
          direccion: _direccionController.text,
        );
      } else {
        await repo.actualizarSede(
          idClienteSede: widget.sede!.idClienteSede,
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          provincia: _provinciaSeleccionada!,
          concello: _concelloSeleccionado!,
          direccion: _direccionController.text,
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
      title: Text(widget.sede == null ? context.l10n.misSedesNueva : context.l10n.misSedesEditar),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _codigoController,
              label: context.l10n.misSedesCodigo,
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.errorNombreRequerido : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nombreController,
              label: context.l10n.misSedesNombreSede,
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.errorNombreRequerido : null,
            ),
            const SizedBox(height: 16),
            ProvinciaConcelloFields(
              provinciaInicial: _provinciaSeleccionada,
              concelloInicial: _concelloSeleccionado,
              onProvinciaChanged: (value) => setState(() {
                _provinciaSeleccionada = value;
                _concelloSeleccionado = null;
              }),
              onConcelloChanged: (value) => setState(() => _concelloSeleccionado = value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _direccionController,
              label: context.l10n.fieldDireccion,
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.errorNombreRequerido : null,
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
