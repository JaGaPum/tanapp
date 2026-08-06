import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cruz_icon.dart';
import '../../../condolencias/presentation/widgets/condolencias_modal.dart';
import '../../data/publicacion_con_sede.dart';
import 'archivar_publicacion_button.dart';
import 'compartir_esquela_button.dart';
import 'condolencias_indicador.dart';
import 'escuchar_esquela_button.dart';
import 'publicacion_detalle.dart';

class PublicacionCard extends ConsumerWidget {
  final PublicacionConSede publicacion;

  const PublicacionCard({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escala = ref.watch(escalaTextoProvider);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(escala)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CruzIcon(size: 20 * escala),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publicacion.nombreFallecido,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  EscucharEsquelaButton(publicacion: publicacion),
                  ArchivarPublicacionButton(
                    idClientePublicacion: publicacion.idClientePublicacion,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PublicacionDetalle(
                publicacion: publicacion,
                trailingLugar: CondolenciasIndicador(
                  numCondolencias: publicacion.numCondolencias,
                  onTap: () => mostrarCondolenciasModal(
                    context,
                    idClientePublicacion: publicacion.idClientePublicacion,
                    nombreFallecido: publicacion.nombreFallecido,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(
                    '/publicacion/${publicacion.idClientePublicacion}/condolencias',
                    extra: {
                      'nombreFallecido': publicacion.nombreFallecido,
                      'idClienteSede': publicacion.idClienteSede,
                    },
                  ),
                  child: Text(context.l10n.publicarCondolencias),
                ),
              ),
              const SizedBox(height: 10),
              CompartirEsquelaButton(publicacion: publicacion),
              const SizedBox(height: 8),
              Text(
                DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(publicacion.fechaAlta.toLocal()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
