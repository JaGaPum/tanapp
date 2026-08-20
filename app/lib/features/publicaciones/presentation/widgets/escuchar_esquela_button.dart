import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/tts/reproduccion_esquela_provider.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../data/publicacion_con_sede.dart';

/// Botón que lee en voz alta los datos de una publicación. A diferencia de [PublicacionDetalle]
/// (que se apoya en iconos para dar contexto a cada dato), aquí no hay iconos, así que cada
/// dato se antepone de una palabra que explica qué es ("Iglesia...", "El funeral será...") —
/// coherente con el tipo real (esquela, misa o acto civil, ver 064), no siempre "funeral".
class EscucharEsquelaButton extends ConsumerWidget {
  final PublicacionConSede publicacion;
  const EscucharEsquelaButton({super.key, required this.publicacion});

  String _textoParaVoz(BuildContext context, String? nombreActoTipo) {
    final p = publicacion;
    final esMisa = nombreActoTipo?.toLowerCase().contains('misa') ?? false;
    final frases = <String>[p.nombreFallecido];

    if (nombreActoTipo != null) {
      frases.add(nombreActoTipo);
    }
    if (p.fechaFallecimiento != null) {
      frases.add(
        context.l10n.publicarFallecioEl(
          DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!),
        ),
      );
    }
    if (p.edad != null) {
      frases.add(context.l10n.publicarAnosDeEdad(p.edad!));
    }
    // Mismo orden que PublicacionDetalle: primero el velorio, luego el entierro/acto.
    if (p.capillaArdiente != null) {
      frases.add(
        '${context.l10n.publicarVelatorioLabel}: ${p.capillaArdiente}',
      );
    }
    if (p.sala != null) {
      frases.add('${context.l10n.publicarSala} ${p.sala}');
    }
    if (p.fechaFuneral != null && p.horaFuneral != null) {
      frases.add(
        p.esActo
            ? (esMisa
                  ? context.l10n.publicarMisaVoz(
                      DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
                      p.horaFuneral!,
                    )
                  : context.l10n.publicarActoVoz(
                      DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
                      p.horaFuneral!,
                    ))
            : context.l10n.publicarFuneralVoz(
                DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
                p.horaFuneral!,
              ),
      );
    } else if (p.fechaFuneral != null) {
      frases.add(
        '${p.esActo ? context.l10n.publicarFechaActo : context.l10n.publicarFechaFuneral} '
        '${DateFormat('dd/MM/yyyy').format(p.fechaFuneral!)}',
      );
    } else if (p.horaFuneral != null) {
      frases.add(
        '${p.esActo ? context.l10n.publicarHoraActo : context.l10n.publicarHoraFuneral} ${p.horaFuneral}',
      );
    }
    // Un acto civil (no religioso) no tiene iglesia, aunque hubiera algo guardado ahí.
    if (p.iglesia != null && (!p.esActo || esMisa)) {
      frases.add(
        '${p.esActo ? context.l10n.publicarIglesiaLocalizacion : context.l10n.publicarIglesia} ${p.iglesia}',
      );
    }
    if (p.lugar != null) {
      frases.add('${context.l10n.publicarLugar} ${p.lugar}');
    }
    if (p.observaciones != null) {
      frases.add(p.observaciones!);
    }
    return frases.join('. ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sonando =
        ref.watch(reproduccionEsquelaProvider) ==
        publicacion.idClientePublicacion;
    final idioma = ref.watch(appLocaleProvider).languageCode == 'gl'
        ? 'gl-ES'
        : 'es-ES';
    final nombreActoTipo = nombreActoTipoDe(
      publicacion,
      ref
          .watch(actoTiposListProvider)
          .maybeWhen(data: (tipos) => tipos, orElse: () => const []),
    );

    return IconButton(
      icon: Icon(
        sonando ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
      ),
      tooltip: sonando
          ? context.l10n.publicarPararEscoita
          : context.l10n.publicarEscoitarEsquela,
      onPressed: () {
        ref
            .read(reproduccionEsquelaProvider.notifier)
            .alternar(
              publicacion.idClientePublicacion,
              _textoParaVoz(context, nombreActoTipo),
              idioma,
            );
      },
    );
  }
}
