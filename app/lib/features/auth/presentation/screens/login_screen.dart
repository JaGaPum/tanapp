import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/apple_sign_in_button.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/facebook_sign_in_button.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/xaga_labs_logo.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../sesiones/application/sesion_policy_service.dart';
import '../../../sistema_usuarios/data/usuarios_repository.dart';
import '../../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  /// true si se llegó aquí desde la opción "Soy una funeraria o tanatorio" de BienvenidaScreen:
  /// cambia el subtítulo y, abajo, el enlace de alta (solicitud de cliente en vez de registro de
  /// usuario particular). El resto (email/contraseña, Google, "¿ya tienes un código?"...) es
  /// igual para los dos, así que se reutiliza la misma pantalla en vez de duplicarla.
  final bool esCliente;

  const LoginScreen({super.key, this.esCliente = false});

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
  bool _loadingFacebook = false;
  bool _loadingApple = false;
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
          roles: perfil.roles,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AppException
              ? e.message
              : context.l10n.errorInesperado,
        );
      }
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
      if (mounted) {
        setState(
          () => _error = e is AppException
              ? e.message
              : context.l10n.errorInesperado,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  Future<void> _submitFacebook() async {
    setState(() {
      _loadingFacebook = true;
      _error = null;
    });
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.signInWithFacebook();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AppException
              ? e.message
              : context.l10n.errorInesperado,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingFacebook = false);
    }
  }

  Future<void> _submitApple() async {
    setState(() {
      _loadingApple = true;
      _error = null;
    });
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.signInWithApple();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AppException
              ? e.message
              : context.l10n.errorInesperado,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingApple = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Interruptores globales del admin (073/074): por defecto Google activo, Facebook y Apple no
    // (p. ej. mientras están pendientes de la revisión de Meta o de dar de alta la cuenta de
    // Apple Developer). "orElse: () => false" es a propósito -mientras carga o si falla, mejor no
    // ofrecer un botón que pueda estar desactivado, que mostrarlo de más un instante-.
    final googleActivo = ref
        .watch(googleLoginActivoProvider)
        .maybeWhen(data: (activo) => activo, orElse: () => false);
    final facebookActivo = ref
        .watch(facebookLoginActivoProvider)
        .maybeWhen(data: (activo) => activo, orElse: () => false);
    final appleActivo = ref
        .watch(appleLoginActivoProvider)
        .maybeWhen(data: (activo) => activo, orElse: () => false);
    return Scaffold(
      // Por si se equivoca de opción (particular/funeraria) en la pantalla anterior: sin esto no
      // hay ninguna forma visible de volver a elegir, solo el gesto/botón "atrás" del sistema.
      appBar: AppBar(),
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
                      Icons.local_florist_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      widget.esCliente
                          ? context.l10n.loginTaglineCliente
                          : context.l10n.loginTagline,
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
                      validator: Validators.required(
                        context,
                        context.l10n.fieldContrasena,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _recordar = !_recordar),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _recordar,
                                onChanged: (v) =>
                                    setState(() => _recordar = v ?? false),
                              ),
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
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/tengo-codigo'),
                        child: Text(context.l10n.loginYaTengoCodigo),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: context.l10n.loginIniciarSesion,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    // Las cuentas de funeraria/tanatorio las da de alta un ADMIN con un email y
                    // contraseña concretos, no son cuentas personales: no tiene sentido ofrecer
                    // aquí un login con Google/Facebook/Apple. Cada botón, además, tiene su
                    // propio interruptor global (073/074, Configuración > Login): puede que
                    // ninguno esté activo, así que el separador "o" solo se muestra si al menos
                    // uno lo está.
                    if (!widget.esCliente &&
                        (googleActivo || facebookActivo || appleActivo)) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              context.l10n.o,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (googleActivo) ...[
                        GoogleSignInButton(
                          label: _loadingGoogle
                              ? context.l10n.googleConectando
                              : context.l10n.googleContinuar,
                          onPressed: _loadingGoogle ? null : _submitGoogle,
                        ),
                        if (facebookActivo || appleActivo)
                          const SizedBox(height: 12),
                      ],
                      if (facebookActivo) ...[
                        FacebookSignInButton(
                          label: _loadingFacebook
                              ? context.l10n.googleConectando
                              : context.l10n.facebookContinuar,
                          onPressed: _loadingFacebook ? null : _submitFacebook,
                        ),
                        if (appleActivo) const SizedBox(height: 12),
                      ],
                      if (appleActivo)
                        AppleSignInButton(
                          label: _loadingApple
                              ? context.l10n.googleConectando
                              : context.l10n.appleContinuar,
                          onPressed: _loadingApple ? null : _submitApple,
                        ),
                    ],
                    const SizedBox(height: 24),
                    if (widget.esCliente)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // Mismo tono suave que la tarjeta de "Tu condolencia"
                          // (CondolenciasScreen): colorScheme.secondary (vino) al 8%.
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_center_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.l10n.loginEresFunerariaPregunta,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () =>
                                    context.push('/solicitud-cliente'),
                                child: Text(context.l10n.loginSolicitarAlta),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
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
