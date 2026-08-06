import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/whatsapp_launcher.dart';
import '../../data/publicacion_con_sede.dart';

/// URL de la ficha de la app en Play Store, para invitar a instalarla a quien reciba la esquela
/// compartida. No sirve de nada hasta que la app esté publicada de verdad ahí.
const _urlPlayStore =
    'https://play.google.com/store/apps/details?id=com.tanapp.tanapp';

/// Verde de marca de WhatsApp, para que el botón se identifique de un vistazo aunque no se lea
/// la etiqueta (mismo criterio que el botón de Google: color + forma reconocibles).
const _verdeWhatsapp = Color(0xFF25D366);

/// Botón ancho (no un icono suelto) para enviar el texto de una esquela por WhatsApp
/// directamente — no el panel genérico de "compartir" del sistema, sino WhatsApp en concreto,
/// para que quede claro de un vistazo a quién va destinado sin tener que elegir en un menú.
class CompartirEsquelaButton extends StatelessWidget {
  final PublicacionConSede publicacion;
  const CompartirEsquelaButton({super.key, required this.publicacion});

  String _texto(BuildContext context) {
    final p = publicacion;
    final bloques = <String>['✝ ${p.nombreFallecido}'];

    final fallecimiento = [
      if (p.fechaFallecimiento != null)
        context.l10n.publicarFallecioEl(
          DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!),
        ),
      if (p.edad != null) context.l10n.publicarAnosDeEdad(p.edad!),
    ].join(' · ');
    if (fallecimiento.isNotEmpty) bloques.add(fallecimiento);

    // Mismo orden que PublicacionDetalle: velorio primero, entierro después.
    final velorio = [
      if (p.capillaArdiente != null)
        '${context.l10n.publicarVelatorioLabel}: ${p.capillaArdiente}',
      if (p.sala != null) '${context.l10n.publicarSala}: ${p.sala}',
    ].join('\n');
    if (velorio.isNotEmpty) bloques.add(velorio);

    final entierroFecha = [
      if (p.fechaFuneral != null)
        DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
      if (p.horaFuneral != null) p.horaFuneral!,
    ].join(' · ');
    final entierro = [
      if (entierroFecha.isNotEmpty)
        '${context.l10n.publicarEntierroLabel}: $entierroFecha',
      if (p.iglesia != null) '${context.l10n.publicarIglesia}: ${p.iglesia}',
      if (p.lugar != null) '${context.l10n.publicarLugar}: ${p.lugar}',
    ].join('\n');
    if (entierro.isNotEmpty) bloques.add(entierro);

    if (p.observaciones != null) bloques.add(p.observaciones!);

    bloques.add(
      '${context.l10n.publicarCompartidoPor} ${p.nombreCliente} · ${p.nombreSede}',
    );
    bloques.add('${context.l10n.publicarDescargaApp} $_urlPlayStore');

    return bloques.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const _IconoWhatsapp(),
        label: Text(context.l10n.publicarCompartirEsquela),
        onPressed: () => compartirPorWhatsapp(_texto(context)),
      ),
    );
  }
}

class _IconoWhatsapp extends StatelessWidget {
  const _IconoWhatsapp();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: _verdeWhatsapp,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.phone, color: Colors.white, size: 14),
    );
  }
}
