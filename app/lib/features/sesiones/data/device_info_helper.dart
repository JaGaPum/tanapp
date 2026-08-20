import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const _longitudMaxima = 200;

/// Descripción legible del dispositivo/navegador desde el que se crea una sesión (062), para
/// que el admin pueda verla en la ficha de usuario. Best-effort: null si no se puede detectar
/// (plataforma no cubierta, o el plugin falla) — la sesión se crea igual, solo sin este dato.
Future<String?> obtenerDescripcionDispositivo() async {
  try {
    final plugin = DeviceInfoPlugin();
    final String? descripcion;
    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      final navegador = info.browserName.name;
      final so = info.platform;
      descripcion = (so == null || so.isEmpty) ? navegador : '$navegador ($so)';
    } else if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      descripcion =
          '${info.manufacturer} ${info.model} · Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      descripcion = '${info.name} · iOS ${info.systemVersion}';
    } else if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      descripcion = 'Windows · ${info.productName}';
    } else if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      descripcion = 'macOS ${info.osRelease}';
    } else if (Platform.isLinux) {
      final info = await plugin.linuxInfo;
      descripcion = 'Linux ${info.prettyName}';
    } else {
      descripcion = null;
    }
    if (descripcion == null) return null;
    return descripcion.length > _longitudMaxima
        ? descripcion.substring(0, _longitudMaxima)
        : descripcion;
  } catch (_) {
    return null;
  }
}
