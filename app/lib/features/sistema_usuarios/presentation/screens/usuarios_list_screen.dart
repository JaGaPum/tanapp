import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../application/usuarios_providers.dart';
import '../../data/catalogos_repository.dart';
import '../../data/usuario_perfil.dart';

class UsuariosListScreen extends ConsumerStatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  ConsumerState<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends ConsumerState<UsuariosListScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(usuariosListParamsProvider);
    final usuariosAsync = ref.watch(usuariosListProvider);
    final rolesAsync = ref.watch(rolesCatalogoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.gestionUsuariosTitulo)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: context.l10n.buscarPorNombreEmail,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => ref.read(usuariosListParamsProvider.notifier).setBusqueda(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(context.l10n.soloActivos),
                  selected: params.soloActivos == true,
                  labelStyle: TextStyle(color: AppColors.chipLabel(params.soloActivos == true)),
                  onSelected: (selected) => ref
                      .read(usuariosListParamsProvider.notifier)
                      .setSoloActivos(selected ? true : null),
                ),
                ChoiceChip(
                  label: Text(context.l10n.todosLosRoles),
                  selected: params.rolCodigo == null,
                  labelStyle: TextStyle(color: AppColors.chipLabel(params.rolCodigo == null)),
                  onSelected: (_) => ref.read(usuariosListParamsProvider.notifier).setRol(null),
                ),
                ...rolesAsync.maybeWhen(
                  data: (roles) => roles.map((rol) {
                    final selected = params.rolCodigo == rol.codigo;
                    return ChoiceChip(
                      label: Text(rol.nombre),
                      selected: selected,
                      labelStyle: TextStyle(color: AppColors.chipLabel(selected)),
                      onSelected: (_) => ref.read(usuariosListParamsProvider.notifier).setRol(rol.codigo),
                    );
                  }),
                  orElse: () => const <Widget>[],
                ),
              ],
            ),
          ),
          Expanded(
            child: usuariosAsync.when(
              data: (usuarios) {
                if (usuarios.isEmpty) {
                  return EmptyState(message: context.l10n.noSeHanEncontradoUsuarios, icon: Icons.people_outline);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(usuariosListProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: usuarios.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _UsuarioTile(usuario: usuarios[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  final UsuarioPerfil usuario;
  const _UsuarioTile({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = usuario.nombreCompleto;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: usuario.activo
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          foregroundColor: Colors.white,
          backgroundImage: usuario.fotoUrl != null ? NetworkImage(usuario.fotoUrl!) : null,
          child: usuario.fotoUrl == null
              ? Text(usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(usuario.email, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            if (nombreCompleto.isNotEmpty) Expanded(child: Text(nombreCompleto)),
            Icon(
              usuario.emailConfirmado ? Icons.verified_outlined : Icons.hourglass_empty,
              size: 16,
              color: usuario.emailConfirmado ? AppColors.green : AppColors.gray,
            ),
            const SizedBox(width: 4),
            Text(
              usuario.emailConfirmado ? context.l10n.validado : context.l10n.pendiente,
              style: TextStyle(fontSize: 12, color: usuario.emailConfirmado ? AppColors.green : AppColors.gray),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          children: usuario.roles.take(2).map((codigo) => Chip(label: Text(codigo))).toList(),
        ),
        onTap: () => context.push('/admin/usuarios/${usuario.idSistemaUsuario}'),
      ),
    );
  }
}
