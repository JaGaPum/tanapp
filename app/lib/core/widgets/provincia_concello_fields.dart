import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/configuracion/application/configuracion_providers.dart';
import '../../features/configuracion/data/provincia.dart';
import '../l10n/l10n_extensions.dart';

class ProvinciaConcelloFields extends ConsumerStatefulWidget {
  final String? provinciaInicial;
  final String? concelloInicial;
  final ValueChanged<String?> onProvinciaChanged;
  final ValueChanged<String?> onConcelloChanged;
  final bool required;

  const ProvinciaConcelloFields({
    super.key,
    this.provinciaInicial,
    this.concelloInicial,
    required this.onProvinciaChanged,
    required this.onConcelloChanged,
    this.required = true,
  });

  @override
  ConsumerState<ProvinciaConcelloFields> createState() => _ProvinciaConcelloFieldsState();
}

class _ProvinciaConcelloFieldsState extends ConsumerState<ProvinciaConcelloFields> {
  late String? _provinciaNombre = widget.provinciaInicial;
  late String? _concelloNombre = widget.concelloInicial;

  @override
  Widget build(BuildContext context) {
    final provinciasAsync = ref.watch(provinciasProvider);

    return provinciasAsync.when(
      data: (provincias) {
        final provinciaValida = provincias.any((p) => p.nombre == _provinciaNombre);
        final provinciaSeleccionada = provinciaValida
            ? provincias.firstWhere((p) => p.nombre == _provinciaNombre)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: provinciaValida ? _provinciaNombre : null,
              decoration: InputDecoration(labelText: context.l10n.fieldProvincia),
              validator:
                  widget.required ? (v) => v == null ? context.l10n.validatorProvinciaRequired : null : null,
              items: provincias.map((p) => DropdownMenuItem(value: p.nombre, child: Text(p.nombre))).toList(),
              onChanged: (value) {
                setState(() {
                  _provinciaNombre = value;
                  _concelloNombre = null;
                });
                widget.onProvinciaChanged(value);
                widget.onConcelloChanged(null);
              },
            ),
            const SizedBox(height: 16),
            _buildConcelloField(provinciaSeleccionada),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(context.l10n.errorCargarProvincias(e.toString())),
    );
  }

  Widget _buildConcelloField(Provincia? provinciaSeleccionada) {
    if (provinciaSeleccionada == null) {
      return DropdownButtonFormField<String>(
        initialValue: null,
        decoration: InputDecoration(labelText: context.l10n.fieldConcello),
        items: const [],
        onChanged: null,
      );
    }

    final concellosAsync = ref.watch(concellosPorProvinciaProvider(provinciaSeleccionada.idConfiguracionProvincia));
    return concellosAsync.when(
      data: (concellos) {
        final concelloValido = concellos.any((c) => c.nombre == _concelloNombre);
        return DropdownButtonFormField<String>(
          initialValue: concelloValido ? _concelloNombre : null,
          decoration: InputDecoration(labelText: context.l10n.fieldConcello),
          validator: widget.required ? (v) => v == null ? context.l10n.validatorConcelloRequired : null : null,
          items: concellos.map((c) => DropdownMenuItem(value: c.nombre, child: Text(c.nombre))).toList(),
          onChanged: (value) {
            setState(() => _concelloNombre = value);
            widget.onConcelloChanged(value);
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(context.l10n.errorCargarConcellos(e.toString())),
    );
  }
}
