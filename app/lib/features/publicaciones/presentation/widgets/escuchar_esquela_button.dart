import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/tts/reproduccion_esquela_provider.dart';
import '../../data/publicacion_con_sede.dart';

/// Botón que lee en voz alta los datos de una esquela. A diferencia de [PublicacionDetalle]
/// (que se apoya en iconos para dar contexto a cada dato), aquí no hay iconos, así que cada
/// dato se antepone de una palabra que explica qué es ("Iglesia...", "El funeral será...").
class EscucharEsquelaButton extends ConsumerWidget {
  final PublicacionConSede publicacion;
  const EscucharEsquelaButton({super.key, required this.publicacion});

  String _textoParaVoz(BuildContext context) {
    final p = publicacion;
    final frases = <String>[p.nombreFallecido];

    if (p.fechaFallecimiento != null) {
      frases.add(context.l10n.publicarFallecioEl(DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!)));
    }
    if (p.edad != null) {
      frases.add(context.l10n.publicarAnosDeEdad(p.edad!));
    }
    if (p.fechaFuneral != null && p.horaFuneral != null) {
      frases.add(
        context.l10n.publicarFuneralVoz(DateFormat('dd/MM/yyyy').format(p.fechaFuneral!), p.horaFuneral!),
      );
    } else if (p.fechaFuneral != null) {
      frases.add('${context.l10n.publicarFechaFuneral} ${DateFormat('dd/MM/yyyy').format(p.fechaFuneral!)}');
    } else if (p.horaFuneral != null) {
      frases.add('${context.l10n.publicarHoraFuneral} ${p.horaFuneral}');
    }
    if (p.iglesia != null) {
      frases.add('${context.l10n.publicarIglesia} ${p.iglesia}');
    }
    if (p.lugar != null) {
      frases.add('${context.l10n.publicarLugar} ${p.lugar}');
    }
    if (p.capillaArdiente != null) {
      final etiqueta = context.l10n.publicarCapillaArdiente.split(' / ').first;
      frases.add('$etiqueta: ${p.capillaArdiente}');
    }
    if (p.sala != null) {
      frases.add('${context.l10n.publicarSala} ${p.sala}');
    }
    if (p.observaciones != null) {
      frases.add(p.observaciones!);
    }
    return frases.join('. ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sonando = ref.watch(reproduccionEsquelaProvider) == publicacion.idClientePublicacion;
    final idioma = ref.watch(appLocaleProvider).languageCode == 'gl' ? 'gl-ES' : 'es-ES';

    return IconButton(
      icon: Icon(sonando ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
      tooltip: sonando ? context.l10n.publicarPararEscoita : context.l10n.publicarEscoitarEsquela,
      onPressed: () {
        ref
            .read(reproduccionEsquelaProvider.notifier)
            .alternar(publicacion.idClientePublicacion, _textoParaVoz(context), idioma);
      },
    );
  }
}
