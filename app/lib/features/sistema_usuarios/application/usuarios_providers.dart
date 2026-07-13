import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/usuario_perfil.dart';
import '../data/usuarios_repository.dart';

class UsuariosListParams {
  final String busqueda;
  final String? rolCodigo;
  final bool? soloActivos;

  const UsuariosListParams({this.busqueda = '', this.rolCodigo, this.soloActivos});

  UsuariosListParams copyWith({
    String? busqueda,
    String? rolCodigo,
    bool clearRol = false,
    bool? soloActivos,
    bool clearActivos = false,
  }) {
    return UsuariosListParams(
      busqueda: busqueda ?? this.busqueda,
      rolCodigo: clearRol ? null : (rolCodigo ?? this.rolCodigo),
      soloActivos: clearActivos ? null : (soloActivos ?? this.soloActivos),
    );
  }
}

class UsuariosListParamsNotifier extends Notifier<UsuariosListParams> {
  @override
  UsuariosListParams build() => const UsuariosListParams();

  void setBusqueda(String value) => state = state.copyWith(busqueda: value);

  void setRol(String? value) =>
      state = value == null ? state.copyWith(clearRol: true) : state.copyWith(rolCodigo: value);

  void setSoloActivos(bool? value) =>
      state = value == null ? state.copyWith(clearActivos: true) : state.copyWith(soloActivos: value);
}

final usuariosListParamsProvider = NotifierProvider<UsuariosListParamsNotifier, UsuariosListParams>(
  UsuariosListParamsNotifier.new,
);

final usuariosListProvider = FutureProvider.autoDispose<List<UsuarioPerfil>>((ref) async {
  final params = ref.watch(usuariosListParamsProvider);
  final repo = ref.watch(usuariosRepositoryProvider);
  return repo.listUsuarios(
    busqueda: params.busqueda,
    rolCodigo: params.rolCodigo,
    soloActivos: params.soloActivos,
  );
});

final usuarioDetailProvider = FutureProvider.autoDispose.family<UsuarioPerfil, String>((ref, id) async {
  final repo = ref.watch(usuariosRepositoryProvider);
  return repo.fetchPerfilById(id);
});
