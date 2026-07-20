import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/publicacion_con_sede.dart';

/// Pinta los campos estructurados de una publicación (fecha/edad, funeral, lugar, capilla
/// ardiente, observaciones), omitiendo los que hayan quedado vacíos.
class PublicacionDetalle extends StatelessWidget {
  final PublicacionConSede publicacion;
  const PublicacionDetalle({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    final p = publicacion;
    final filas = <Widget>[];

    if (p.fechaFallecimiento != null || p.edad != null) {
      final partes = [
        if (p.fechaFallecimiento != null)
          context.l10n.publicarFallecioEl(DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!)),
        if (p.edad != null) context.l10n.publicarAnosDeEdad(p.edad!),
      ];
      filas.add(_Fila(icon: Icons.event_outlined, texto: partes.join(' · ')));
    }
    if (p.fechaFuneral != null || p.horaFuneral != null) {
      final partesFuneral = [
        if (p.fechaFuneral != null) DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
        if (p.horaFuneral != null) p.horaFuneral!,
      ];
      filas.add(_Fila(icon: Icons.schedule, texto: partesFuneral.join(' · ')));
    }
    if (p.iglesia != null) {
      filas.add(_Fila(icon: Icons.church_outlined, texto: p.iglesia!));
    }
    if (p.lugar != null) {
      filas.add(_Fila(icon: Icons.place_outlined, texto: p.lugar!));
    }
    if (p.capillaArdiente != null) {
      filas.add(_Fila(icon: Icons.local_florist_outlined, texto: p.capillaArdiente!));
    }
    if (p.sala != null) {
      filas.add(_Fila(icon: Icons.meeting_room_outlined, texto: '${context.l10n.publicarSala} ${p.sala}'));
    }

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
