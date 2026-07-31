import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../cliente_sedes/application/cliente_sedes_providers.dart';
import '../../application/avisos_providers.dart';
import '../../data/avisos_repository.dart';

class AvisoFormScreen extends ConsumerStatefulWidget {
  const AvisoFormScreen({super.key});

  @override
  ConsumerState<AvisoFormScreen> createState() => _AvisoFormScreenState();
}

class _AvisoFormScreenState extends ConsumerState<AvisoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _textoController = TextEditingController();
  String? _idClienteSedeSeleccionada;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate() || _idClienteSedeSeleccionada == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(avisosRepositoryProvider).crearAviso(
            idClienteSede: _idClienteSedeSeleccionada!,
            titulo: _tituloController.text,
            texto: _textoController.text,
          );
      ref.invalidate(misAvisosEnviadosProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.avisosEnviadoOk)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedesAsync = ref.watch(misSedesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.avisosFormTitulo)),
      body: sedesAsync.when(
        data: (sedes) {
          if (sedes.isEmpty) {
            return EmptyState(message: context.l10n.publicarSinSedes, icon: Icons.storefront_outlined);
          }
          _idClienteSedeSeleccionada ??= sedes.first.idClienteSede;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ErrorBanner(message: _error!),
                  if (sedes.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _idClienteSedeSeleccionada,
                      decoration: InputDecoration(labelText: context.l10n.publicarSeleccionaSede),
                      items: sedes
                          .map(
                            (sede) => DropdownMenuItem(
                              value: sede.idClienteSede,
                              child: Text('${sede.codigo} · ${sede.nombre}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _idClienteSedeSeleccionada = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    controller: _tituloController,
                    label: context.l10n.avisosTituloLabel,
                    validator: Validators.required(context, context.l10n.avisosTituloLabel),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _textoController,
                    label: context.l10n.avisosTextoLabel,
                    maxLines: 6,
                    validator: Validators.required(context, context.l10n.avisosTextoLabel),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: context.l10n.avisosEnviar,
                    loading: _loading,
                    onPressed: _enviar,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}
