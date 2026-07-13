import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/provincia_concello_fields.dart';
import '../../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _telefonoController = TextEditingController();
  String? _provinciaSeleccionada;
  String? _concelloSeleccionado;
  bool _loading = false;
  bool _loadingGoogle = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUpUsuarioOrdinario(
            email: _emailController.text,
            password: _passwordController.text,
            nombre: _nombreController.text,
            apellido1: _apellido1Controller.text,
            apellido2: _apellido2Controller.text,
            telefono: _telefonoController.text,
            concello: _concelloSeleccionado,
            provincia: _provinciaSeleccionada,
          );
      if (mounted) {
        context.push('/register/verify', extra: _emailController.text.trim());
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.registerTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ErrorBanner(message: _error!),
                    AppTextField(
                      controller: _nombreController,
                      label: context.l10n.fieldNombre,
                      validator: Validators.required(context, context.l10n.fieldNombre),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _apellido1Controller,
                      label: context.l10n.fieldPrimerApellido,
                      validator: Validators.required(context, context.l10n.fieldPrimerApellido),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: _apellido2Controller, label: context.l10n.fieldSegundoApellidoOpcional),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.fieldEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email(context),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _telefonoController,
                      label: context.l10n.fieldTelefonoOpcional,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    ProvinciaConcelloFields(
                      provinciaInicial: _provinciaSeleccionada,
                      concelloInicial: _concelloSeleccionado,
                      onProvinciaChanged: (value) => setState(() => _provinciaSeleccionada = value),
                      onConcelloChanged: (value) => setState(() => _concelloSeleccionado = value),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(controller: _passwordController, validator: Validators.password(context)),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmController,
                      label: context.l10n.fieldConfirmarContrasena,
                      validator: Validators.confirmPassword(context, () => _passwordController.text),
                    ),
                    const SizedBox(height: 24),
                    AppButton(label: context.l10n.registerTitle, loading: _loading, onPressed: _submit),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(context.l10n.o, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GoogleSignInButton(
                      label: _loadingGoogle ? context.l10n.googleConectando : context.l10n.googleRegistrarse,
                      onPressed: _loadingGoogle ? null : _submitGoogle,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(context.l10n.registerYaTengoCuenta),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
