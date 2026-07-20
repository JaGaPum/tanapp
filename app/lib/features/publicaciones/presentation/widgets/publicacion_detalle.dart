import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/publicacion_con_sede.dart';

/// Pinta los campos estructurados de una publicación (fecha/edad, funeral, lugar, capilla
/// ardiente, observaciones), omitiendo los que hayan quedado vacíos.
class PublicacionDetalle extends StatelessWidget {
  final PublicacionConSede publicacion;
  const PublicacionDetalle({super.key, required this.publicacion});

  /// Icono + texto de cada dato cubierto, en el mismo orden en que se pintan. Se expone aparte
  /// del build() para poder reutilizarlo al construir el texto que se lee en voz alta.
  static List<(IconData, String)> items(BuildContext context, PublicacionConSede p) {
    final items = <(IconData, String)>[];

    if (p.fechaFallecimiento != null || p.edad != null) {
      final partes = [
        if (p.fechaFallecimiento != null)
          context.l10n.publicarFallecioEl(DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!)),
        if (p.edad != null) context.l10n.publicarAnosDeEdad(p.edad!),
      ];
      items.add((Icons.event_outlined, partes.join(' · ')));
    }
    if (p.fechaFuneral != null || p.horaFuneral != null) {
      final partesFuneral = [
        if (p.fechaFuneral != null) DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
        if (p.horaFuneral != null) p.horaFuneral!,
      ];
      items.add((Icons.schedule, partesFuneral.join(' · ')));
    }
    if (p.iglesia != null) {
      items.add((Icons.church_outlined, p.iglesia!));
    }
    if (p.lugar != null) {
      items.add((Icons.place_outlined, p.lugar!));
    }
    if (p.capillaArdiente != null) {
      items.add((Icons.local_florist_outlined, p.capillaArdiente!));
    }
    if (p.sala != null) {
      items.add((Icons.meeting_room_outlined, '${context.l10n.publicarSala} ${p.sala}'));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final p = publicacion;
    final filas = [
      for (final (icon, texto) in items(context, p)) _Fila(icon: icon, texto: texto),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final fila in filas) ...[fila, const SizedBox(height: 4)],
        if (p.observaciones != null) ...[
          const SizedBox(height: 4),
          Text(p.observaciones!, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _Fila({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}
