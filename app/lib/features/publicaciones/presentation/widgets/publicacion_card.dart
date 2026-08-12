import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/widgets/cruz_icon.dart';
import '../../../condolencias/presentation/widgets/condolencias_modal.dart';
import '../../data/publicacion_con_sede.dart';
import 'archivar_publicacion_button.dart';
import 'compartir_esquela_button.dart';
import 'condolencias_indicador.dart';
import 'escuchar_esquela_button.dart';
import 'publicacion_detalle.dart';

/// Tarjeta de una esquela: misma tarjeta tanto en el Taboleiro/Arquivo/Seguindo (uso normal) como
/// en "Mis publicaciones" del cliente dueño (pasando [esPropia] y los callbacks de editar/
/// eliminar) — así el cliente ve su propia esquela exactamente igual que la ve cualquier usuario,
/// con sus acciones de gestión añadidas encima en vez de una tarjeta aparte con otro aspecto.
class PublicacionCard extends ConsumerWidget {
  final PublicacionConSede publicacion;
  final bool esPropia;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final bool eliminando;

  const PublicacionCard({
    super.key,
    required this.publicacion,
    this.esPropia = false,
    this.onEditar,
    this.onEliminar,
    this.eliminando = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escala = ref.watch(escalaTextoProvider);
    return Card(
      // Blanco (el de por defecto del tema) con sombra en vez de borde negro: la tarjeta se
      // distingue del fondo por elevación, no por un contorno marcado.
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  // Archivar es para guardarla en el Arquivo personal de un seguidor: no tiene
                  // sentido que el propio cliente "archive" su propia esquela.
                  if (!esPropia)
                    ArchivarPublicacionButton(
                      idClientePublicacion: publicacion.idClientePublicacion,
                    ),
                ],
              ),
              if (esPropia) ...[
                const SizedBox(height: 2),
                Text(
                  publicacion.concello,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
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
              if (esPropia) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(context.l10n.editar),
                      onPressed: eliminando ? null : onEditar,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(context.l10n.eliminar),
                      onPressed: eliminando ? null : onEliminar,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
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
                  // El dueño no deja su propia condolencia aquí: entra a revisar/moderar las que
                  // le han dejado a él.
                  child: Text(
                    esPropia
                        ? context.l10n.publicarVerCondolencias
                        : context.l10n.publicarCondolencias,
                  ),
                ),
              ),
              // Compartir por WhatsApp es para que un seguidor la reenvíe: no tiene sentido que
              // el propio cliente "comparta" su propia esquela desde aquí.
              if (!esPropia) ...[
                const SizedBox(height: 10),
                CompartirEsquelaButton(publicacion: publicacion),
              ],
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
