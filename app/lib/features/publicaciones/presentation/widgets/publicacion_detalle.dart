import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../data/publicacion_con_sede.dart';

/// Pinta los campos estructurados de una publicación, agrupados por evento (falleció -> velorio
/// -> entierro) y con una etiqueta de texto delante de cada dato (no solo el icono), para que
/// se entienda de un vistazo sin tener que interpretar iconos. Omite los campos vacíos.
///
/// Para un acto (misa u otro, 064) los grupos de "velorio" no aplican -sus campos vienen vacíos
/// de por sí- y se antepone una fila con el tipo de acto.
class PublicacionDetalle extends ConsumerWidget {
  final PublicacionConSede publicacion;

  /// Se pinta al final de la fila de "Lugar" (alineado a la derecha), en vez de en su propia
  /// fila, para no añadirle altura al bloque de detalles.
  final Widget? trailingLugar;
  const PublicacionDetalle({
    super.key,
    required this.publicacion,
    this.trailingLugar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = publicacion;
    final textTheme = Theme.of(context).textTheme;
    final estiloTexto = textTheme.bodyLarge?.copyWith(
      fontSize: (textTheme.bodyLarge?.fontSize ?? 16) + 1,
    );
    final nombreActoTipo = nombreActoTipoDe(
      p,
      ref
          .watch(actoTiposListProvider)
          .maybeWhen(data: (tipos) => tipos, orElse: () => const []),
    );
    // Un acto civil (no religioso) no muestra iglesia, aunque hubiera algo guardado ahí.
    final esMisa = nombreActoTipo?.toLowerCase().contains('misa') ?? false;
    final mostrarIglesia = !p.esActo || esMisa;

    final basico = <Widget>[
      if (nombreActoTipo != null)
        _Fila(
          icon: Icons.category_outlined,
          style: estiloTexto,
          texto: nombreActoTipo,
        ),
      if (p.fechaFallecimiento != null || p.edad != null)
        _Fila(
          icon: Icons.event_outlined,
          style: estiloTexto,
          texto: [
            if (p.fechaFallecimiento != null)
              context.l10n.publicarFallecioEl(
                DateFormat('dd/MM/yyyy').format(p.fechaFallecimiento!),
              ),
            if (p.edad != null) context.l10n.publicarAnosDeEdad(p.edad!),
          ].join(' · '),
        ),
    ];

    final velorio = <Widget>[
      if (p.capillaArdiente != null)
        _Fila(
          icon: Icons.local_florist_outlined,
          style: estiloTexto,
          etiqueta: context.l10n.publicarVelatorioLabel,
          texto: p.capillaArdiente!,
        ),
      if (p.sala != null)
        _Fila(
          icon: Icons.meeting_room_outlined,
          style: estiloTexto,
          etiqueta: context.l10n.publicarSala,
          texto: p.sala!,
        ),
    ];

    final enterro = <Widget>[
      if (p.fechaFuneral != null || p.horaFuneral != null)
        _Fila(
          icon: Icons.schedule,
          style: estiloTexto,
          etiqueta: p.esActo
              ? context.l10n.publicarActoLabel
              : context.l10n.publicarEntierroLabel,
          texto: [
            if (p.fechaFuneral != null)
              DateFormat('dd/MM/yyyy').format(p.fechaFuneral!),
            if (p.horaFuneral != null) p.horaFuneral!,
          ].join(' · '),
        ),
      if (p.iglesia != null && mostrarIglesia)
        _Fila(
          icon: Icons.church_outlined,
          style: estiloTexto,
          etiqueta: p.esActo
              ? context.l10n.publicarIglesiaLocalizacion
              : context.l10n.publicarIglesia,
          texto: p.iglesia!,
        ),
      if (p.lugar != null)
        _Fila(
          icon: Icons.place_outlined,
          style: estiloTexto,
          etiqueta: context.l10n.publicarLugar,
          texto: p.lugar!,
          trailing: trailingLugar,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final fila in basico) ...[fila, const SizedBox(height: 4)],
        for (final fila in velorio) ...[fila, const SizedBox(height: 4)],
        // Separación extra entre los dos grupos (aparte de las etiquetas), para que se note el
        // cambio de evento aunque no se lean los textos.
        if (velorio.isNotEmpty && enterro.isNotEmpty) const SizedBox(height: 4),
        for (final fila in enterro) ...[fila, const SizedBox(height: 4)],
        if (p.observaciones != null) ...[
          const SizedBox(height: 4),
          Text(p.observaciones!, style: estiloTexto),
        ],
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String? etiqueta;
  final String texto;
  final Widget? trailing;
  final TextStyle? style;
  const _Fila({
    required this.icon,
    this.etiqueta,
    required this.texto,
    this.trailing,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: style ?? Theme.of(context).textTheme.bodyLarge,
              children: [
                if (etiqueta != null)
                  TextSpan(
                    text: '$etiqueta: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                TextSpan(text: texto),
              ],
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
