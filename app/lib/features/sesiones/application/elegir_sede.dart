import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../cliente_sedes/data/cliente_sede.dart';
import '../data/sesion.dart';
import '../data/sesiones_repository.dart';
import 'sesiones_providers.dart';

/// Asigna [sede] a [sesionActual]. Si ya hay 2 sesiones de este mismo usuario trabajando como
/// esa sede, avisa de que continuar cerrará la más antigua y solo sigue si el usuario confirma.
/// Devuelve true si se ha asignado, false si el usuario ha cancelado.
Future<bool> elegirSedeParaSesion({
  required BuildContext context,
  required WidgetRef ref,
  required Sesion sesionActual,
  required ClienteSede sede,
}) async {
  final repo = ref.read(sesionesRepositoryProvider);
  final otras = await repo.contarOtrasSesionesAbiertasSede(
    idSistemaUsuario: sesionActual.idSistemaUsuario,
    idClienteSede: sede.idClienteSede,
    excluirIdSistemaSesion: sesionActual.idSistemaSesion,
  );
  if (otras >= 2) {
    if (!context.mounted) return false;
    final continuar = await showConfirmDialog(
      context,
      title: context.l10n.sedeLimiteTitulo,
      message: context.l10n.sedeLimiteMensaje(sede.nombre),
      confirmLabel: context.l10n.sedeLimiteConfirmar,
    );
    if (!continuar) return false;
    await repo.cerrarSesionMasAntiguaDeSede(
      idSistemaUsuario: sesionActual.idSistemaUsuario,
      idClienteSede: sede.idClienteSede,
      excluirIdSistemaSesion: sesionActual.idSistemaSesion,
    );
  }
  await repo.asignarSede(
    idSistemaSesion: sesionActual.idSistemaSesion,
    idClienteSede: sede.idClienteSede,
  );
  ref.invalidate(sesionActualProvider);
  return true;
}
