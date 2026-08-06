import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/suplantacion_repository.dart';

/// Refresh token de la sesión ORIGINAL del administrador, guardado justo antes de intercambiarla
/// por la del usuario suplantado; null si no se está suplantando a nadie ahora mismo. Es lo
/// único que hace falta para poder volver ("setSession" recupera una sesión completa a partir
/// de un refresh token).
class SesionAdminGuardadaNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> suplantar(String idSistemaUsuarioObjetivo) async {
    final client = Supabase.instance.client;
    final refreshTokenAdmin = client.auth.currentSession?.refreshToken;
    if (refreshTokenAdmin == null) {
      throw Exception('No hay sesión de administrador activa');
    }
    await ref
        .read(suplantacionRepositoryProvider)
        .suplantarUsuario(idSistemaUsuarioObjetivo);
    // Solo se guarda una vez confirmado el cambio de sesión: si "suplantarUsuario" lanza, el
    // admin se queda en su propia sesión de siempre, sin banner de "volver" a medias.
    state = refreshTokenAdmin;
  }

  Future<void> volver() async {
    final refreshToken = state;
    if (refreshToken == null) return;
    state = null;
    await Supabase.instance.client.auth.setSession(refreshToken);
  }
}

final sesionAdminGuardadaProvider =
    NotifierProvider<SesionAdminGuardadaNotifier, String?>(
      SesionAdminGuardadaNotifier.new,
    );
