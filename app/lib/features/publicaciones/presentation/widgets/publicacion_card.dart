import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/preferences/escala_texto_provider.dart';
import '../../data/publicacion_con_sede.dart';
import 'archivar_publicacion_button.dart';
import 'escuchar_esquela_button.dart';
import 'publicacion_detalle.dart';

class PublicacionCard extends ConsumerWidget {
  final PublicacionConSede publicacion;

  const PublicacionCard({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escala = ref.watch(escalaTextoProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(escala)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(publicacion.nombreFallecido, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  EscucharEsquelaButton(publicacion: publicacion),
                  ArchivarPublicacionButton(idClientePublicacion: publicacion.idClientePublicacion),
                ],
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
      ),
    );
  }
}
