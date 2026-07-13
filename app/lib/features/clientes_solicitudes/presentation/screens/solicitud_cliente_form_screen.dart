import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/provincia_concello_fields.dart';
import '../../data/solicitudes_repository.dart';

class SolicitudClienteFormScreen extends ConsumerStatefulWidget {
  const SolicitudClienteFormScreen({super.key});

  @override
  ConsumerState<SolicitudClienteFormScreen> createState() => _SolicitudClienteFormScreenState();
}

class _SolicitudClienteFormScreenState extends ConsumerState<SolicitudClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razonSocialController = TextEditingController();
  final _nifCifController = TextEditingController();
  final _nombreContactoController = TextEditingController();
  final _emailContactoController = TextEditingController();
  final _telefonoContactoController = TextEditingController();
  final _observacionesController = TextEditingController();
  String? _provinciaSeleccionada;
  String? _concelloSeleccionado;
  bool _loading = false;
  bool _enviado = false;
  String? _error;

  @override
  void dispose() {
    _razonSocialController.dispose();
    _nifCifController.dispose();
    _nombreContactoController.dispose();
    _emailContactoController.dispose();
    _telefonoContactoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(solicitudesRepositoryProvider).crearSolicitud(
            razonSocial: _razonSocialController.text,
            nifCif: _nifCifController.text,
            nombreContacto: _nombreContactoController.text,
            emailContacto: _emailContactoController.text,
            telefonoContacto: _telefonoContactoController.text,
            localidad: _concelloSeleccionado,
            provincia: _provinciaSeleccionada,
            observaciones: _observacionesController.text,
          );
      if (mounted) setState(() => _enviado = true);
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.solicitudTitulo)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _enviado ? _buildConfirmacion(context) : _buildFormulario(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmacion(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(context.l10n.solicitudEnviadaTitulo, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          context.l10n.solicitudEnviadaMensaje,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AppButton(label: context.l10n.volverAlInicio, onPressed: () => context.go('/login')),
      ],
    );
  }

  Widget _buildFormulario(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.solicitudIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (_error != null) ErrorBanner(message: _error!),
          AppTextField(
            controller: _razonSocialController,
            label: context.l10n.fieldRazonSocial,
            validator: Validators.required(context, context.l10n.fieldRazonSocial),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nifCifController,
            label: context.l10n.fieldNifCif,
            validator: Validators.required(context, context.l10n.fieldNifCif),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nombreContactoController,
            label: context.l10n.fieldNombreContacto,
            validator: Validators.required(context, context.l10n.fieldNombreContacto),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _emailContactoController,
            label: context.l10n.fieldEmailContacto,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email(context),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _telefonoContactoController,
            label: context.l10n.fieldTelefonoContacto,
            keyboardType: TextInputType.phone,
            validator: Validators.required(context, context.l10n.fieldTelefonoContacto),
          ),
          const SizedBox(height: 16),
          ProvinciaConcelloFields(
            provinciaInicial: _provinciaSeleccionada,
            concelloInicial: _concelloSeleccionado,
            onProvinciaChanged: (value) => setState(() => _provinciaSeleccionada = value),
            onConcelloChanged: (value) => setState(() => _concelloSeleccionado = value),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _observacionesController,
            label: context.l10n.fieldObservacionesOpcional,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          AppButton(label: context.l10n.enviarSolicitud, loading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          Center(
            child: TextButton(onPressed: () => context.pop(), child: Text(context.l10n.volver)),
          ),
        ],
      ),
    );
  }
}
