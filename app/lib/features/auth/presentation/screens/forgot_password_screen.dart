import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// false para el enlace "¿Ya tienes un código?" de Login: un cliente recién aprobado (o
  /// cualquiera con un código de recuperación aún válido en el correo) no necesita que se le
  /// mande uno nuevo — eso invalidaría el que ya tiene — solo confirmar su email para pasar
  /// directamente a la pantalla de introducirlo.
  final bool enviarCodigoNuevo;
  const ForgotPasswordScreen({super.key, this.enviarCodigoNuevo = true});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.enviarCodigoNuevo) {
        await ref
            .read(authRepositoryProvider)
            .requestPasswordReset(email: _emailController.text);
      }
      if (mounted) {
        context.push(
          '/forgot-password/verify',
          extra: _emailController.text.trim(),
        );
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
      appBar: AppBar(
        title: Text(
          widget.enviarCodigoNuevo
              ? context.l10n.forgotPasswordTitle
              : context.l10n.tengoCodigoTitulo,
        ),
      ),
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
                    Text(
                      widget.enviarCodigoNuevo
                          ? context.l10n.forgotPasswordIntro
                          : context.l10n.tengoCodigoIntro,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ErrorBanner(message: _error!),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.fieldEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email(context),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: widget.enviarCodigoNuevo
                          ? context.l10n.forgotPasswordEnviarCodigo
                          : context.l10n.tengoCodigoContinuar,
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
