import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Envoltorio fino sobre flutter_tts: solo lo que necesita la app (leer una esquela en voz
/// alta, pararla, y saber cuándo termina).
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> hablar(String texto, {required String idioma}) async {
    await _tts.setLanguage(idioma);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(texto);
  }

  Future<void> detener() => _tts.stop();

  void alTerminar(void Function() callback) {
    _tts.setCompletionHandler(callback);
    _tts.setCancelHandler(callback);
    _tts.setErrorHandler((_) => callback());
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.detener);
  return service;
});
