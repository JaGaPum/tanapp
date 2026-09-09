import 'package:http/http.dart' as http;

import '../utils/app_exception.dart';

/// Mensaje mostrado cuando una petición a Supabase falla por falta de conexión a internet (wifi/
/// datos apagados, sin cobertura...), en vez del error técnico crudo (p. ej. "SocketException:
/// Failed host lookup" o "ClientException: Failed to fetch" en web) que se vería si no se
/// intercepta aquí.
const mensajeSinConexion =
    'Sin conexión a internet. Comprueba tu conexión e inténtalo de nuevo.';

/// Envuelve el cliente http real para convertir cualquier fallo de conectividad en un
/// [AppException] con un mensaje claro, antes de que llegue a Postgrest/GoTrue: Postgrest deja
/// pasar la excepción tal cual tras agotar sus reintentos, y GoTrue la reenvuelve en una
/// "AuthRetryableFetchException" cuyo mensaje es el "toString()" de esta -que, al ser un
/// AppException, es directamente el texto de abajo, sin ruido técnico-. Se instala una sola vez
/// en Supabase.initialize(httpClient: ...) (ver main.dart) y así todas las pantallas de la app
/// -que ya distinguen un AppException del resto, o simplemente muestran "e.toString()"- enseñan
/// este mensaje sin tener que tocar cada pantalla una por una.
class HttpClienteConDeteccionDeRed extends http.BaseClient {
  final http.Client _interno;
  HttpClienteConDeteccionDeRed([http.Client? interno])
    : _interno = interno ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _interno.send(request);
    } catch (e) {
      if (_esFalloDeConexion(e)) {
        throw AppException(mensajeSinConexion);
      }
      rethrow;
    }
  }
}

bool _esFalloDeConexion(Object error) {
  final texto = error.toString().toLowerCase();
  return texto.contains('socketexception') ||
      texto.contains('failed host lookup') ||
      texto.contains('failed to fetch') ||
      texto.contains('clientexception') ||
      texto.contains('connection failed') ||
      texto.contains('connection refused') ||
      texto.contains('network is unreachable') ||
      texto.contains('software caused connection abort');
}
