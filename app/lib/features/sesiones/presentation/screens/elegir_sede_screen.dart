import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../../cliente_sedes/data/cliente_sede.dart';
import '../../application/elegir_sede.dart';
import '../../application/sesion_policy_service.dart';
import '../../application/sesiones_providers.dart';

/// Gate del router (como "aceptar-terminos"): un CLIENTE con más de una sede tiene que indicar
/// con cuál va a trabajar esta sesión antes de entrar en la app. Con una sola sede no hace
/// falta preguntar — SesionPolicyService ya se la asigna sola en el login.
class ElegirSedeScreen extends ConsumerStatefulWidget {
  const ElegirSedeScreen({super.key});

  @override
  ConsumerState<ElegirSedeScreen> createState() => _ElegirSedeScreenState();
}

class _ElegirSedeScreenState extends ConsumerState<ElegirSedeScreen> {
  String? _idSedeEligiendo;
  String? _error;

  Future<void> _elegir(ClienteSede sede) async {
    setState(() {
      _idSedeEligiendo = sede.idClienteSede;
      _error = null;
    });
    try {
      final perfil = await ref.read(currentUserProfileProvider.future);
      final sesionActual = await ref.read(sesionActualProvider.future);
      if (perfil == null || sesionActual == null || !mounted) return;
      final asignada = await elegirSedeParaSesion(
        context: context,
        ref: ref,
        sesionActual: sesionActual,
        sede: sede,
      );
      if (!mounted) return;
      if (asignada) {
        ref.read(sesionBootstrapGuardProvider).necesitaElegirSede = false;
        context.go('/home');
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = context.l10n.errorGenerico(e.toString()));
      }
    }
    if (mounted) setState(() => _idSedeEligiendo = null);
  }

  @override
  Widget build(BuildContext context) {
    final sedesAsync = ref.watch(misSedesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.elegirSedeTitulo),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: sedesAsync.when(
          data: (sedes) => ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              if (_error != null) ErrorBanner(message: _error!),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  context.l10n.elegirSedeMensaje,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              for (final sede in sedes)
                Card(
                  child: ListTile(
                    title: Text(sede.nombre),
                    subtitle: Text('${sede.codigo} · ${sede.concello}'),
                    trailing: _idSedeEligiendo == sede.idClienteSede
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _idSedeEligiendo == null
                        ? () => _elegir(sede)
                        : null,
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(context.l10n.errorGenerico(e.toString()))),
        ),
      ),
    );
  }
}
