import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cruz_icon.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
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
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final estiloNombre = textTheme.titleLarge?.copyWith(
      fontSize: (textTheme.titleLarge?.fontSize ?? 22) + 1,
    );
    final estiloConcello = textTheme.titleSmall?.copyWith(
      fontSize: (textTheme.titleSmall?.fontSize ?? 14) + 1,
    );
    final estiloFecha = textTheme.bodySmall?.copyWith(
      fontSize: (textTheme.bodySmall?.fontSize ?? 12) + 1,
      color: Theme.of(context).colorScheme.outline,
    );
    // El chip dice "Misa" o "Acto" según lo que de verdad sea el tipo elegido (p. ej. "Acto
    // Civil" no es una misa): se mira el nombre resuelto del catálogo, no el tipo genérico.
    final nombreActoTipo = nombreActoTipoDe(
      publicacion,
      ref
          .watch(actoTiposListProvider)
          .maybeWhen(data: (tipos) => tipos, orElse: () => const []),
    );
    final esMisa = nombreActoTipo?.toLowerCase().contains('misa') ?? false;
    // Container en vez de Card: la sombra de Card (elevation) solo se nota por abajo, y aquí
    // hace falta un poco también por arriba para que la tarjeta no quede pegada a la de encima.
    // Además del boxShadow (difuso, apenas visible entre tarjeta y tarjeta) se añade un borde
    // fino para que se note bien el contorno completo de la tarjeta, no solo un degradado leve.
    return Container(
      decoration: BoxDecoration(
        color: esOscuro ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esOscuro
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
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
                  publicacion.esActo
                      ? Icon(
                          esMisa
                              ? Icons.church_outlined
                              : Icons.groups_outlined,
                          size: 20 * escala,
                          color: AppColors.black,
                        )
                      : CruzIcon(size: 20 * escala),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publicacion.nombreFallecido,
                      style: estiloNombre,
                    ),
                  ),
                  if (publicacion.esActo) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        esMisa
                            ? context.l10n.publicarMisaLabel
                            : context.l10n.publicarActoLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12 * escala,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
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
                  context.l10n.publicarPublicadoPorSede(
                    publicacion.nombreCliente,
                    publicacion.nombreSede,
                  ),
                  style: estiloConcello,
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
                // Mismo ancho que el botón de condolencias de debajo (a partes iguales entre los
                // dos), en vez de un Wrap de píldoras compactas: como bloque, queda más ordenado.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(context.l10n.editar),
                        onPressed: eliminando ? null : onEditar,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline),
                        label: Text(context.l10n.eliminar),
                        onPressed: eliminando ? null : onEliminar,
                      ),
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
                style: estiloFecha,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
