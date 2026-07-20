import 'package:url_launcher/url_launcher.dart';

/// Abre Google Maps (app si está instalada, si no el navegador) con la ruta hasta la
/// dirección indicada. No usamos coordenadas: Google Maps resuelve el texto de la
/// dirección al abrir el enlace, así que basta con una dirección postal razonable.
Future<void> abrirIndicacionesGoogleMaps({
  required String direccion,
  String? concello,
  String? provincia,
}) async {
  final destino = [direccion, concello, provincia].where((s) => s != null && s.trim().isNotEmpty).join(', ');
  final uri = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': destino});
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
