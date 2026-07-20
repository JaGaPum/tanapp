import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tts_service.dart';

/// Id de la publicación cuya esquela se está leyendo en voz alta ahora mismo (null si ninguna).
/// Solo puede sonar una a la vez: empezar a leer otra para automáticamente la anterior.
class ReproduccionEsquelaNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> alternar(String idClientePublicacion, String texto, String idioma) async {
    final tts = ref.read(ttsServiceProvider);
    final yaSonando = state == idClientePublicacion;
    await tts.detener();
    if (yaSonando) {
      state = null;
      return;
    }
    state = idClientePublicacion;
    tts.alTerminar(() {
      if (state == idClientePublicacion) state = null;
    });
    await tts.hablar(texto, idioma: idioma);
  }
}

final reproduccionEsquelaProvider = NotifierProvider<ReproduccionEsquelaNotifier, String?>(
  ReproduccionEsquelaNotifier.new,
);
