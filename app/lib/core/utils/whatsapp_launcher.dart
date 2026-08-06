import 'package:url_launcher/url_launcher.dart';

/// Abre WhatsApp (app si está instalada, si no WhatsApp Web) con [texto] ya escrito, listo para
/// elegir el contacto o grupo al que enviarlo. "wa.me" es una URL https normal, así que no hace
/// falta ningún permiso ni intent-filter especial en Android (a diferencia de "tel:").
Future<void> compartirPorWhatsapp(String texto) async {
  final uri = Uri.https('wa.me', '/', {'text': texto});
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
