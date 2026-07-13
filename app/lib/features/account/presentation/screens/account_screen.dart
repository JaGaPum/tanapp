import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/provincia_concello_fields.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../sistema_usuarios/data/catalogos_repository.dart';
import '../../../sistema_usuarios/data/usuario_perfil.dart';
import '../../../sistema_usuarios/data/usuarios_repository.dart';

TextStyle? _sectionTitleStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountTitle)),
      body: perfilAsync.when(
        data: (perfil) => perfil == null
            ? Center(child: Text(context.l10n.accountNoSePudoCargarPerfil))
            : _AccountBody(perfil: perfil),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _AccountBody extends StatelessWidget {
  final UsuarioPerfil perfil;
  const _AccountBody({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.accountFotoPerfil, style: _sectionTitleStyle(context)),
              const SizedBox(height: 16),
              Center(child: _FotoPerfilSection(perfil: perfil)),
              const SizedBox(height: 40),
              Text(context.l10n.accountDatosPersonales, style: _sectionTitleStyle(context)),
              const SizedBox(height: 16),
              _DatosPersonalesForm(perfil: perfil),
              const SizedBox(height: 40),
              const _CambiarPasswordSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FotoPerfilSection extends ConsumerStatefulWidget {
  final UsuarioPerfil perfil;
  const _FotoPerfilSection({required this.perfil});

  @override
  ConsumerState<_FotoPerfilSection> createState() => _FotoPerfilSectionState();
}

class _FotoPerfilSectionState extends ConsumerState<_FotoPerfilSection> {
  bool _subiendo = false;
  String? _error;

  String _extensionDesde(XFile archivo) {
    final nombre = archivo.name;
    final punto = nombre.lastIndexOf('.');
    if (punto != -1 && punto < nombre.length - 1) return nombre.substring(punto + 1).toLowerCase();
    final mime = archivo.mimeType;
    if (mime == 'image/png') return 'png';
    if (mime == 'image/webp') return 'webp';
    return 'jpg';
  }

  String _contentTypeDesde(XFile archivo, String extension) {
    return archivo.mimeType ?? switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  Future<void> _elegirFoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _subiendo = true;
      _error = null;
    });
    try {
      final bytes = await picked.readAsBytes();
      final extension = _extensionDesde(picked);
      await ref.read(usuariosRepositoryProvider).subirFoto(
            idSistemaUsuario: widget.perfil.idSistemaUsuario,
            authId: widget.perfil.idAuthSupabase,
            bytes: bytes,
            extension: extension,
            contentType: _contentTypeDesde(picked, extension),
          );
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.accountFotoActualizada)));
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.accountNoSePudoSubirFoto);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = [widget.perfil.nombre, widget.perfil.apellido1]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim()[0].toUpperCase())
        .join();

    return Column(
      children: [
        if (_error != null) ErrorBanner(message: _error!),
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.brown,
              backgroundImage: widget.perfil.fotoUrl != null ? NetworkImage(widget.perfil.fotoUrl!) : null,
              child: widget.perfil.fotoUrl == null
                  ? Text(
                      iniciales.isNotEmpty ? iniciales : '?',
                      style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.black,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: _subiendo
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.photo_camera_outlined, color: AppColors.white, size: 20),
                  onPressed: _subiendo ? null : _elegirFoto,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatosPersonalesForm extends ConsumerStatefulWidget {
  final UsuarioPerfil perfil;
  const _DatosPersonalesForm({required this.perfil});

  @override
  ConsumerState<_DatosPersonalesForm> createState() => _DatosPersonalesFormState();
}

class _DatosPersonalesFormState extends ConsumerState<_DatosPersonalesForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellido1Controller;
  late final TextEditingController _apellido2Controller;
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  String? _provinciaSeleccionada;
  String? _concelloSeleccionado;
  String? _idiomaSeleccionado;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.perfil.nombre);
    _apellido1Controller = TextEditingController(text: widget.perfil.apellido1 ?? '');
    _apellido2Controller = TextEditingController(text: widget.perfil.apellido2 ?? '');
    _telefonoController = TextEditingController(text: widget.perfil.telefono ?? '');
    _emailController = TextEditingController(text: widget.perfil.email);
    _provinciaSeleccionada = widget.perfil.provincia;
    _concelloSeleccionado = widget.perfil.concello;
    _idiomaSeleccionado = widget.perfil.idSistemaIdiomaPreferido;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(usuariosRepositoryProvider).updatePerfil(
            idSistemaUsuario: widget.perfil.idSistemaUsuario,
            nombre: _nombreController.text,
            apellido1: _apellido1Controller.text,
            apellido2: _apellido2Controller.text,
            telefono: _telefonoController.text,
            concello: _concelloSeleccionado,
            provincia: _provinciaSeleccionada,
            idSistemaIdiomaPreferido: _idiomaSeleccionado,
            activo: widget.perfil.activo,
          );
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.accountDatosActualizados)));
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ErrorBanner(message: _error!),
          AppTextField(controller: _emailController, label: context.l10n.fieldEmail, enabled: false),
          const SizedBox(height: 16),
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
          AppTextField(controller: _apellido2Controller, label: context.l10n.fieldSegundoApellido),
          const SizedBox(height: 16),
          AppTextField(
            controller: _telefonoController,
            label: context.l10n.fieldTelefono,
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
          ref.watch(idiomasCatalogoProvider).when(
                data: (idiomas) => DropdownButtonFormField<String>(
                  initialValue: _idiomaSeleccionado,
                  decoration: InputDecoration(labelText: context.l10n.usuarioIdiomaPreferido),
                  items: idiomas
                      .map((idioma) => DropdownMenuItem(value: idioma.idSistemaIdioma, child: Text(idioma.nombre)))
                      .toList(),
                  onChanged: (value) => setState(() => _idiomaSeleccionado = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(context.l10n.errorCargarIdiomas(e.toString())),
              ),
          const SizedBox(height: 16),
          AppButton(label: context.l10n.accountGuardarCambios, loading: _loading, onPressed: _guardar),
        ],
      ),
    );
  }
}

class _CambiarPasswordSection extends StatefulWidget {
  const _CambiarPasswordSection();

  @override
  State<_CambiarPasswordSection> createState() => _CambiarPasswordSectionState();
}

class _CambiarPasswordSectionState extends State<_CambiarPasswordSection> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_expandido)
          AppButton(
            label: context.l10n.accountCambiarContrasena,
            secondary: true,
            onPressed: () => setState(() => _expandido = true),
          )
        else
          _CambiarPasswordForm(onCompletado: () => setState(() => _expandido = false)),
      ],
    );
  }
}

class _CambiarPasswordForm extends ConsumerStatefulWidget {
  final VoidCallback onCompletado;
  const _CambiarPasswordForm({required this.onCompletado});

  @override
  ConsumerState<_CambiarPasswordForm> createState() => _CambiarPasswordFormState();
}

class _CambiarPasswordFormState extends ConsumerState<_CambiarPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _actualController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final actualizadaMensaje = context.l10n.accountContrasenaActualizada;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final email = authRepo.currentUser?.email;
      if (email == null) {
        setState(() => _error = context.l10n.accountNoSePudoVerificarIdentidad);
        return;
      }
      try {
        await authRepo.signInWithPassword(email: email, password: _actualController.text);
      } catch (_) {
        setState(() => _error = context.l10n.accountContrasenaActualIncorrecta);
        return;
      }
      await authRepo.updatePassword(newPassword: _passwordController.text);
      _actualController.clear();
      _passwordController.clear();
      _confirmController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(actualizadaMensaje)));
        widget.onCompletado();
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ErrorBanner(message: _error!),
          PasswordField(
            controller: _actualController,
            label: context.l10n.accountContrasenaActual,
            validator: Validators.required(context, context.l10n.accountContrasenaActual),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _passwordController,
            label: context.l10n.resetPasswordNuevaContrasena,
            validator: Validators.password(context),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _confirmController,
            label: context.l10n.fieldConfirmarContrasena,
            validator: Validators.confirmPassword(context, () => _passwordController.text),
          ),
          const SizedBox(height: 16),
          AppButton(label: context.l10n.accountActualizarContrasena, loading: _loading, onPressed: _guardar),
        ],
      ),
    );
  }
}
