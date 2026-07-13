import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/xaga_labs_logo.dart';
import '../../../sesiones/application/sesion_policy_service.dart';
import '../../../sistema_usuarios/data/usuarios_repository.dart';
import '../../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _recordar = false;
  bool _loading = false;
  bool _loadingGoogle = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defensa adicional al redirect del router: si se llega aquí (p.ej. con el botón
    // "atrás" del navegador) mientras la sesión sigue activa, no se debe pedir login de nuevo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Supabase.instance.client.auth.currentSession != null) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    // Se capturan del `ref` ANTES de cualquier `await`: en cuanto el login tenga éxito el
    // router puede redirigir a /home y desmontar esta pantalla, y usar `ref` después de eso
    // lanza una excepción (igual que ocurría con el cierre de sesión en el drawer).
    final authRepo = ref.read(authRepositoryProvider);
    final usuariosRepo = ref.read(usuariosRepositoryProvider);
    final sesionPolicy = ref.read(sesionPolicyServiceProvider);
    final cuentaDesactivadaMensaje = context.l10n.cuentaDesactivada;
    ref.read(sesionBootstrapGuardProvider).completado = true;
    try {
      await authRepo.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = authRepo.currentUser;
      if (user != null) {
        final perfil = await usuariosRepo.fetchPerfilByAuthId(user.id);
        if (perfil == null || !perfil.activo) {
          await authRepo.signOut();
          throw AppException(cuentaDesactivadaMensaje);
        }
        await sesionPolicy.registrarLoginExplicito(
          idSistemaUsuario: perfil.idSistemaUsuario,
          recordar: _recordar,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _error = null;
    });
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.signInWithGoogle();
    } catch (e) {
      if (mounted) setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Icon(Icons.local_florist_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      context.l10n.loginTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ErrorBanner(message: _error!),
                    AppTextField(
                      controller: _emailController,
                      label: context.l10n.fieldEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email(context),
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passwordController,
                      validator: Validators.required(context, context.l10n.fieldContrasena),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _recordar = !_recordar),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(value: _recordar, onChanged: (v) => setState(() => _recordar = v ?? false)),
                              Text(context.l10n.loginRecordarme),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(context.l10n.loginOlvidasteContrasena),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(label: context.l10n.loginIniciarSesion, loading: _loading, onPressed: _submit),
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
                      label: _loadingGoogle ? context.l10n.googleConectando : context.l10n.googleContinuar,
                      onPressed: _loadingGoogle ? null : _submitGoogle,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.loginNoTienesCuenta),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(context.l10n.loginRegistrate),
                        ),
                      ],
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/solicitud-cliente'),
                        child: Text(context.l10n.loginEresFuneraria),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Center(child: XagaLabsLogo()),
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
