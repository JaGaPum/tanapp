import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../application/condolencias_providers.dart';

/// Vista previa rápida de las condolencias de una esquela, sin salir de donde esté el usuario
/// (Taboleiro, Arquivo...). Para escribir/editar la propia condolencia sigue haciendo falta
/// entrar en la pantalla completa (aquí solo se listan, de lectura).
Future<void> mostrarCondolenciasModal(
  BuildContext context, {
  required String idClientePublicacion,
  required String nombreFallecido,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CondolenciasModal(
      idClientePublicacion: idClientePublicacion,
      nombreFallecido: nombreFallecido,
    ),
  );
}

class _CondolenciasModal extends ConsumerWidget {
  final String idClientePublicacion;
  final String nombreFallecido;
  const _CondolenciasModal({
    required this.idClientePublicacion,
    required this.nombreFallecido,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condolenciasAsync = ref.watch(
      condolenciasVistaPreviaProvider(idClientePublicacion),
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.condolenciasTitulo(nombreFallecido),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: condolenciasAsync.when(
                data: (condolencias) {
                  if (condolencias.isEmpty) {
                    return Center(child: Text(context.l10n.condolenciasVacio));
                  }
                  return ListView.separated(
                    itemCount: condolencias.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final condolencia = condolencias[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              condolencia.nombreAutor,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condolencia.texto,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(condolencia.fechaAlta.toLocal()),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(context.l10n.errorGenerico(e.toString())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
