import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/provincia_concello_fields.dart';
import '../../../sesiones/application/sesiones_providers.dart';
import '../../application/usuarios_providers.dart';
import '../../data/catalogos_repository.dart';
import '../../data/usuario_perfil.dart';
import '../../data/usuarios_repository.dart';

TextStyle? _sectionTitleStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

String _formatFecha(DateTime dt) {
  final local = dt.toLocal();
  String dosDigitos(int n) => n.toString().padLeft(2, '0');
  return '${dosDigitos(local.day)}/${dosDigitos(local.month)}/${local.year} '
      '${dosDigitos(local.hour)}:${dosDigitos(local.minute)}';
}

class UsuarioDetailScreen extends ConsumerWidget {
  final String idSistemaUsuario;
  const UsuarioDetailScreen({super.key, required this.idSistemaUsuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(usuarioDetailProvider(idSistemaUsuario));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.usuarioFichaTitulo)),
      body: perfilAsync.when(
        data: (perfil) => _UsuarioForm(perfil: perfil),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _UsuarioForm extends ConsumerStatefulWidget {
  final UsuarioPerfil perfil;
  const _UsuarioForm({required this.perfil});

  @override
  ConsumerState<_UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends ConsumerState<_UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellido1Controller;
  late final TextEditingController _apellido2Controller;
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  String? _idiomaSeleccionado;
  String? _provinciaSeleccionada;
  String? _concelloSeleccionado;
  late bool _activo;
  bool _loading = false;
  bool _mostrarSesiones = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.perfil.nombre);
    _apellido1Controller = TextEditingController(text: widget.perfil.apellido1 ?? '');
    _apellido2Controller = TextEditingController(text: widget.perfil.apellido2 ?? '');
    _telefonoController = TextEditingController(text: widget.perfil.telefono ?? '');
    _emailController = TextEditingController(text: widget.perfil.email);
    _idiomaSeleccionado = widget.perfil.idSistemaIdiomaPreferido;
    _provinciaSeleccionada = widget.perfil.provincia;
    _concelloSeleccionado = widget.perfil.concello;
    _activo = widget.perfil.activo;
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

  void _invalidateUsuario() {
    ref.invalidate(usuarioDetailProvider(widget.perfil.idSistemaUsuario));
    ref.invalidate(usuariosListProvider);
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
            activo: _activo,
          );
      _invalidateUsuario();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.usuarioCambiosGuardados)));
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _agregarRol(RolCatalogo rol) async {
    try {
      await ref.read(usuariosRepositoryProvider).asignarRol(
            idSistemaUsuario: widget.perfil.idSistemaUsuario,
            idSistemaRol: rol.idSistemaRol,
          );
      _invalidateUsuario();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.usuarioNoSePudoAsignarRol);
    }
  }

  Future<void> _quitarRol(RolAsignado rol) async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.usuarioQuitarRolTitulo,
      message: context.l10n.usuarioQuitarRolMensaje(rol.nombre),
      confirmLabel: context.l10n.usuarioQuitar,
    );
    if (!confirmado) return;
    try {
      await ref.read(usuariosRepositoryProvider).quitarRol(idSistemaUsuarioRol: rol.idSistemaUsuarioRol);
      _invalidateUsuario();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.usuarioNoSePudoQuitarRol);
    }
  }

  Future<void> _mostrarSelectorRoles() async {
    final catalogo = await ref.read(rolesCatalogoProvider.future);
    final asignados = widget.perfil.roles.toSet();
    final disponibles = catalogo.where((r) => !asignados.contains(r.codigo)).toList();
    if (!mounted) return;
    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.usuarioYaTieneTodosLosRoles)));
      return;
    }
    final seleccionado = await showModalBottomSheet<RolCatalogo>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: disponibles
              .map((rol) => ListTile(title: Text(rol.nombre), onTap: () => Navigator.of(context).pop(rol)))
              .toList(),
        ),
      ),
    );
    if (seleccionado != null) await _agregarRol(seleccionado);
  }

  Future<void> _confirmarEmail() async {
    try {
      await ref.read(usuariosRepositoryProvider).confirmarEmail(widget.perfil.idSistemaUsuario);
      _invalidateUsuario();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.usuarioEmailValidado)));
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.usuarioNoSePudoValidarEmail);
    }
  }

  Future<void> _eliminarUsuario() async {
    final confirmado = await showConfirmDialog(
      context,
      title: context.l10n.usuarioEliminarTitulo,
      message: context.l10n.usuarioEliminarMensaje(widget.perfil.nombreCompleto),
      confirmLabel: context.l10n.usuarioEliminar,
    );
    if (!confirmado) return;
    final usuariosRepo = ref.read(usuariosRepositoryProvider);
    try {
      await usuariosRepo.eliminarUsuario(widget.perfil.idSistemaUsuario);
      ref.invalidate(usuariosListProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.usuarioNoSePudoEliminar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idiomasAsync = ref.watch(idiomasCatalogoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Form(
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
              idiomasAsync.when(
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
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(context.l10n.usuarioActivo),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              AppButton(label: context.l10n.accountGuardarCambios, loading: _loading, onPressed: _guardar),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.validacionEmail, style: _sectionTitleStyle(context)),
                  if (!widget.perfil.emailConfirmado)
                    TextButton(onPressed: _confirmarEmail, child: Text(context.l10n.marcarComoValidado))
                  else
                    Chip(
                      avatar: const Icon(Icons.verified_outlined, color: AppColors.green, size: 18),
                      label: Text(context.l10n.validado),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.roles, style: _sectionTitleStyle(context)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: context.l10n.anadirRol,
                    onPressed: _mostrarSelectorRoles,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.perfil.rolesAsignados
                    .map((rol) => InputChip(label: Text(rol.nombre), onDeleted: () => _quitarRol(rol)))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.sesiones, style: _sectionTitleStyle(context)),
                  TextButton.icon(
                    icon: Icon(_mostrarSesiones ? Icons.expand_less : Icons.expand_more),
                    label: Text(_mostrarSesiones ? context.l10n.ocultarSesiones : context.l10n.verSesiones),
                    onPressed: () => setState(() => _mostrarSesiones = !_mostrarSesiones),
                  ),
                ],
              ),
              if (_mostrarSesiones)
                ref.watch(usuarioSesionesProvider(widget.perfil.idSistemaUsuario)).when(
                      data: (sesiones) => sesiones.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(context.l10n.sinSesionesRegistradas),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text(context.l10n.sesionColInicio)),
                                  DataColumn(label: Text(context.l10n.sesionColFin)),
                                  DataColumn(label: Text(context.l10n.sesionColEstado)),
                                  DataColumn(label: Text(context.l10n.sesionColRecordar)),
                                ],
                                rows: sesiones
                                    .map(
                                      (sesion) => DataRow(
                                        cells: [
                                          DataCell(Text(_formatFecha(sesion.fechaInicio))),
                                          DataCell(Text(
                                            sesion.fechaFin != null
                                                ? _formatFecha(sesion.fechaFin!)
                                                : context.l10n.sesionEnCurso,
                                          )),
                                          DataCell(Text(
                                            sesion.abierta ? context.l10n.sesionAbierta : context.l10n.sesionCerrada,
                                          )),
                                          DataCell(Text(sesion.recordar ? context.l10n.si : context.l10n.no)),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => Text(context.l10n.errorCargarSesiones(e.toString())),
                    ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(context.l10n.usuarioEliminar, style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                onPressed: _eliminarUsuario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
