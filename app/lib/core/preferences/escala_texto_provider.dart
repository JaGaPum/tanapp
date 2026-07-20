import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Escala de texto aplicada a los datos de las esquelas (Taboleiro, Arquivo, Mis publicacións),
/// pensada para usuarios mayores que necesiten letra más grande. Es una preferencia del
/// dispositivo (no del perfil), persistida en SharedPreferences.
class EscalaTextoNotifier extends Notifier<double> {
  static const _clave = 'escalaTextoEsquelas';
  static const valores = [0.85, 1.0, 1.15, 1.3, 1.45];

  @override
  double build() {
    _cargar();
    return 1.0;
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getDouble(_clave);
    if (guardado != null && valores.contains(guardado)) {
      state = guardado;
    }
  }

  void aumentar() => _cambiar(1);
  void disminuir() => _cambiar(-1);

  void _cambiar(int paso) {
    final indiceActual = valores.indexOf(state);
    final indiceNuevo = (indiceActual == -1 ? 1 : indiceActual + paso).clamp(0, valores.length - 1);
    state = valores[indiceNuevo];
    SharedPreferences.getInstance().then((prefs) => prefs.setDouble(_clave, state));
  }
}

final escalaTextoProvider = NotifierProvider<EscalaTextoNotifier, double>(EscalaTextoNotifier.new);
