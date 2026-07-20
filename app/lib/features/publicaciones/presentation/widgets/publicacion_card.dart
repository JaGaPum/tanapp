import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/publicacion_con_sede.dart';
import 'archivar_publicacion_button.dart';
import 'publicacion_detalle.dart';

class PublicacionCard extends StatelessWidget {
  final PublicacionConSede publicacion;

  const PublicacionCard({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(publicacion.nombreFallecido, style: Theme.of(context).textTheme.titleLarge),
                ),
                ArchivarPublicacionButton(idClientePublicacion: publicacion.idClientePublicacion),
              ],
            ),
            Text(
              publicacion.concello,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            PublicacionDetalle(publicacion: publicacion),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(publicacion.fechaAlta.toLocal()),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
