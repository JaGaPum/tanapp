import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dispositivos_push_repository.dart';

/// Pide permiso de notificaciones y mantiene registrado en el backend el token de FCM del
/// dispositivo actual. No falla la app si el usuario deniega el permiso: simplemente no llega
/// ningún push (el aviso dentro de la app funciona igual).
class PushService {
  final DispositivosPushRepository _repo;
  PushService(this._repo);

  Future<void> inicializar() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) await _repo.registrarToken(token);

    messaging.onTokenRefresh.listen(_repo.registrarToken);
  }
}

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(ref.watch(dispositivosPushRepositoryProvider));
});
