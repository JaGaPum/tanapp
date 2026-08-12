import 'package:url_launcher/url_launcher.dart';

/// Abre el cliente de correo del dispositivo con el destinatario, asunto y cuerpo ya escritos,
/// listo para revisar y enviar. No hay envío desde la propia app (no hay backend de correo
/// saliente propio): quien escribe lo manda desde su cuenta de correo habitual.
Future<bool> enviarCorreo({
  required String destinatario,
  required String asunto,
  required String cuerpo,
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: destinatario,
    queryParameters: {'subject': asunto, 'body': cuerpo},
  );
  return launchUrl(uri);
}
