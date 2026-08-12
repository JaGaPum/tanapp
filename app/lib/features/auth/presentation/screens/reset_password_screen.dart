import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/password_field.dart';
import '../../data/auth_repository.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final actualizadaMensaje = context.l10n.resetPasswordActualizada;
      await repo.updatePassword(newPassword: _passwordController.text);
      // Ya hay una sesión válida (la abrió "verifyRecoveryOtp" antes de llegar aquí, con su
      // TSistemaSesiones ya registrada por el router): en vez de cerrarla y mandar a /login a
      // volver a autenticarse, se entra directo. Si hace falta aceptar términos o elegir sede,
      // el redirect del router ya se encarga de interceptar "/home" y llevar a donde toque.
      if (mounted) {
        context.go('/home');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actualizadaMensaje)));
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.resetPasswordTitle)),
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
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.resetPasswordInfo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ErrorBanner(message: _error!),
                    PasswordField(
                      controller: _passwordController,
                      label: context.l10n.resetPasswordNuevaContrasena,
                      validator: Validators.password(context),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmController,
                      label: context.l10n.fieldConfirmarContrasena,
                      validator: Validators.confirmPassword(
                        context,
                        () => _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: context.l10n.resetPasswordGuardar,
                      loading: _loading,
                      onPressed: _submit,
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
