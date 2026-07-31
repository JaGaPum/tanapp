import 'package:url_launcher/url_launcher.dart';

/// Abre el marcador de teléfono del dispositivo con el número ya escrito, listo para llamar.
Future<void> llamarTelefono(String telefono) async {
  final uri = Uri(scheme: 'tel', path: telefono.trim());
  await launchUrl(uri);
}
