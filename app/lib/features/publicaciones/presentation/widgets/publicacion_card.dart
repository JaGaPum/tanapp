import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/preferences/escala_texto_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cruz_icon.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../condolencias/presentation/widgets/condolencias_modal.dart';
import '../../../recordatorios/application/recordatorios_providers.dart';
import '../../../recordatorios/presentation/widgets/recordatorio_modal.dart';
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
    // Un cliente (con su cuenta de cliente) no configura recordatorios; si tiene una cuenta
    // personal vinculada de usuario ordinario (067), sí puede, porque esa sesión ya no tiene el
    // rol CLIENTE (070). Al ser una condición de rol, no de "esPropia" -esta tarjeta nunca se
    // pinta con esPropia=true si el usuario actual no es cliente-, no hace falta comprobar las
    // dos cosas por separado.
    final puedeConfigurarRecordatorio = !ref.watch(isClienteProvider);
    final fechaHoraEvento = publicacion.fechaHoraEvento;
    final eventoTodaviaNoPasado =
        fechaHoraEvento != null && fechaHoraEvento.isAfter(DateTime.now());
    // Solo se pide si el botón va a mostrarse (evita una consulta de más por tarjeta cuando ni
    // siquiera aplica, p. ej. la del propio cliente en su cuenta de cliente).
    final numRecordatorios =
        puedeConfigurarRecordatorio && eventoTodaviaNoPasado
        ? ref
              .watch(
                recordatoriosPendientesPorPublicacionProvider(
                  publicacion.idClientePublicacion,
                ),
              )
              .maybeWhen(data: (r) => r.length, orElse: () => 0)
        : 0;
    final colorBorde = esOscuro
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.12);
    // Container en vez de Card: la sombra de Card (elevation) solo se nota por abajo, y aquí
    // hace falta un poco también por arriba para que la tarjeta no quede pegada a la de encima.
    // Además del boxShadow (difuso, apenas visible entre tarjeta y tarjeta) se añade un borde
    // fino para que se note bien el contorno completo de la tarjeta, no solo un degradado leve.
    //
    // Un acto (misa u otro, 064) se distingue de una esquela con un sello circular centrado a
    // caballo del borde superior (vino con iglesia/grupo dentro; la esquela lleva uno negro con
    // la cruz) -recuerda a un sello de cera sobre una carta formal- en vez de un filete de color
    // en un lateral, para que la marca quede siempre en el mismo sitio y sea una única señal
    // (icono + color juntos) en vez de dos sueltas. Va dentro del ClipRRect para que su mitad de
    // arriba quede recortada justo por el borde redondeado de la tarjeta, como si estuviera
    // incrustado en el borde; el ClipRRect en sí es aparte del Container de fuera para que el
    // boxShadow de la tarjeta no se recorte también (el ClipRRect no puede envolver a ambos).
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: esOscuro ? AppColors.darkSurface : AppColors.white,
            border: Border.all(color: colorBorde),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(escala)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barra de acciones aparte (no junto al nombre): con la cruz y el nombre
                  // centrados, como en una esquela real, ya no cabían en la misma fila.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EscucharEsquelaButton(publicacion: publicacion),
                      // Archivar es para guardarla en el Arquivo personal de un seguidor: no
                      // tiene sentido que el propio cliente "archive" su propia esquela.
                      if (!esPropia)
                        ArchivarPublicacionButton(
                          idClientePublicacion:
                              publicacion.idClientePublicacion,
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      publicacion.esActo
                          ? _Sello(
                              icon: esMisa
                                  ? Icons.church_outlined
                                  : Icons.groups_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                              colorAnillo: esOscuro
                                  ? AppColors.darkSurface
                                  : AppColors.white,
                            )
                          : _Sello(
                              esCruz: true,
                              color: AppColors.black,
                              colorAnillo: esOscuro
                                  ? AppColors.darkSurface
                                  : AppColors.white,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        publicacion.nombreFallecido.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: estiloNombre?.copyWith(letterSpacing: 1),
                      ),
                      if (nombreActoTipo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          nombreActoTipo.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12 * escala,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                      if (esPropia) ...[
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.publicarPublicadoPorSede(
                            publicacion.nombreCliente,
                            publicacion.nombreSede,
                          ),
                          textAlign: TextAlign.center,
                          style: estiloConcello,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: colorBorde),
                  const SizedBox(height: 16),
                  PublicacionDetalle(
                    publicacion: publicacion,
                    // Un acto (misa u otro) no admite condolencias: no es un fallecimiento
                    // recién ocurrido, no tiene sentido "dar el pésame" ahí (069).
                    trailingLugar: publicacion.esActo
                        ? null
                        : CondolenciasIndicador(
                            numCondolencias: publicacion.numCondolencias,
                            onTap: () => mostrarCondolenciasModal(
                              context,
                              idClientePublicacion:
                                  publicacion.idClientePublicacion,
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
                  // Un acto no admite condolencias (069): ni el botón de dejarlas/gestionarlas
                  // tiene sentido aquí.
                  if (!publicacion.esActo) ...[
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
                        // El dueño no deja su propia condolencia aquí: entra a revisar/moderar
                        // las que le han dejado a él.
                        child: Text(
                          esPropia
                              ? context.l10n.publicarVerCondolencias
                              : context.l10n.publicarCondolencias,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Recordatorio (070): solo tiene sentido si hay una fecha/hora de evento
                  // todavía por llegar -si no, cualquier fecha que se eligiera sería inválida-.
                  if (puedeConfigurarRecordatorio && eventoTodaviaNoPasado) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.alarm_add_outlined),
                        // El número va al final del texto (no sobre el icono): con el botón
                        // ocupando todo el ancho, un badge sobre el icono queda lejos de donde
                        // se lee "Recordatorio", y así se lee todo junto de un vistazo.
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.l10n.recordatorioBoton),
                            if (numRecordatorios > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$numRecordatorios',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onPressed: () => mostrarRecordatorioModal(
                          context,
                          idClientePublicacion:
                              publicacion.idClientePublicacion,
                          fechaHoraEvento: fechaHoraEvento,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Compartir por WhatsApp es para que un seguidor la reenvíe: no tiene sentido que
                  // el propio cliente "comparta" su propia esquela desde aquí.
                  if (!esPropia)
                    CompartirEsquelaButton(publicacion: publicacion),
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
        ),
      ),
    );
  }
}

/// Marca del tipo de publicación, a modo de sello de cera sobre una carta formal: un círculo de
/// color con el icono dentro y un anillo del mismo tono que el fondo de la tarjeta (para que se
/// note el corte limpio entre uno y otro). Sustituye al icono suelto + filete de color que había
/// antes: una sola señal (posición fija, arriba centrada) en vez de dos sueltas y en lados
/// distintos según el tipo.
class _Sello extends StatelessWidget {
  final IconData? icon;
  final bool esCruz;
  final Color color;
  final Color colorAnillo;

  const _Sello({
    this.icon,
    this.esCruz = false,
    required this.color,
    required this.colorAnillo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: colorAnillo, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: esCruz
            ? const CruzIcon(size: 16, color: Colors.white)
            : Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
