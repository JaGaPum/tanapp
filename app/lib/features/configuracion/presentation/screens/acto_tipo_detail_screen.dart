import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../acto_tipos/application/acto_tipos_providers.dart';
import '../../../acto_tipos/data/acto_tipo.dart';
import '../../../acto_tipos/data/acto_tipos_repository.dart';

class ActoTipoDetailScreen extends ConsumerWidget {
  final String? idConfiguracionActoTipo;
  const ActoTipoDetailScreen({super.key, this.idConfiguracionActoTipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = idConfiguracionActoTipo;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.actoTipoNuevo)),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: const Center(child: _ActoTipoForm(actoTipo: null)),
        ),
      );
    }

    final actoTipoAsync = ref.watch(actoTipoDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.actoTipoEditar)),
      body: actoTipoAsync.when(
        data: (actoTipo) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Center(child: _ActoTipoForm(actoTipo: actoTipo)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _ActoTipoForm extends ConsumerStatefulWidget {
  final ActoTipo? actoTipo;
  const _ActoTipoForm({required this.actoTipo});

  @override
  ConsumerState<_ActoTipoForm> createState() => _ActoTipoFormState();
}

class _ActoTipoFormState extends ConsumerState<_ActoTipoForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(
    text: widget.actoTipo?.nombre ?? '',
  );
  late bool _activo = widget.actoTipo?.activo ?? true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(actoTiposRepositoryProvider);
    try {
      if (widget.actoTipo == null) {
        final nuevoId = await repo.crearActoTipo(
          nombre: _nombreController.text,
          activo: _activo,
        );
        ref.invalidate(actoTiposListProvider);
        if (mounted) {
          context.pushReplacement('/admin/configuracion/tipos-acto/$nuevoId');
        }
      } else {
        await repo.actualizarActoTipo(
          idConfiguracionActoTipo: widget.actoTipo!.idConfiguracionActoTipo,
          nombre: _nombreController.text,
          activo: _activo,
        );
        ref.invalidate(actoTiposListProvider);
        ref.invalidate(
          actoTipoDetailProvider(widget.actoTipo!.idConfiguracionActoTipo),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.cambiosGuardados)),
          );
        }
      }
    } catch (e) {
      setState(
        () => _error = e is AppException
            ? e.message
            : context.l10n.errorInesperado,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _nombreController,
              label: context.l10n.fieldNombre,
              validator: Validators.required(context, context.l10n.fieldNombre),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(context.l10n.actoTipoActivo),
              value: _activo,
              onChanged: (value) => setState(() => _activo = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: context.l10n.guardar,
              loading: _loading,
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
