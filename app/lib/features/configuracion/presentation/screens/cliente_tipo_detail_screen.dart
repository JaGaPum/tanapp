import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../cliente_tipos/application/cliente_tipos_providers.dart';
import '../../../cliente_tipos/data/cliente_tipo.dart';
import '../../../cliente_tipos/data/cliente_tipos_repository.dart';
import '../../../sistema_usuarios/data/catalogos_repository.dart';

class ClienteTipoDetailScreen extends ConsumerWidget {
  final String? idConfiguracionClienteTipo;
  const ClienteTipoDetailScreen({super.key, this.idConfiguracionClienteTipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = idConfiguracionClienteTipo;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.clienteTipoNuevo)),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Center(child: _ClienteTipoForm(clienteTipo: null)),
        ),
      );
    }

    final clienteTipoAsync = ref.watch(clienteTipoDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.clienteTipoEditar)),
      body: clienteTipoAsync.when(
        data: (clienteTipo) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(child: _ClienteTipoForm(clienteTipo: clienteTipo)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _ClienteTipoForm extends ConsumerStatefulWidget {
  final ClienteTipo? clienteTipo;
  const _ClienteTipoForm({required this.clienteTipo});

  @override
  ConsumerState<_ClienteTipoForm> createState() => _ClienteTipoFormState();
}

class _ClienteTipoFormState extends ConsumerState<_ClienteTipoForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreController = TextEditingController(text: widget.clienteTipo?.nombre ?? '');
  late bool _activo = widget.clienteTipo?.activo ?? true;
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
    final repo = ref.read(clienteTiposRepositoryProvider);
    try {
      if (widget.clienteTipo == null) {
        final nuevoId = await repo.crearClienteTipo(nombre: _nombreController.text, activo: _activo);
        ref.invalidate(clienteTiposListProvider);
        if (mounted) context.pushReplacement('/admin/configuracion/tipos-cliente/$nuevoId');
      } else {
        await repo.actualizarClienteTipo(
          idConfiguracionClienteTipo: widget.clienteTipo!.idConfiguracionClienteTipo,
          nombre: _nombreController.text,
          activo: _activo,
        );
        ref.invalidate(clienteTiposListProvider);
        ref.invalidate(clienteTipoDetailProvider(widget.clienteTipo!.idConfiguracionClienteTipo));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.cambiosGuardados)));
        }
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.errorInesperado);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
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
                  title: Text(context.l10n.clienteTipoActivo),
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                AppButton(label: context.l10n.guardar, loading: _loading, onPressed: _guardar),
              ],
            ),
          ),
          if (widget.clienteTipo != null) ...[
            const SizedBox(height: 40),
            Text(
              context.l10n.clienteTipoTraduccionesPorIdioma,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _TraduccionesSection(clienteTipo: widget.clienteTipo!),
          ],
        ],
      ),
    );
  }
}

class _TraduccionesSection extends ConsumerWidget {
  final ClienteTipo clienteTipo;
  const _TraduccionesSection({required this.clienteTipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idiomasAsync = ref.watch(idiomasCatalogoProvider);
    return idiomasAsync.when(
      data: (idiomas) => Column(
        children: [
          for (final idioma in idiomas) ...[
            _TraduccionCard(
              clienteTipo: clienteTipo,
              idIdioma: idioma.idSistemaIdioma,
              nombreIdioma: idioma.nombre,
              traduccionExistente: clienteTipo.traducciones
                  .where((t) => t.idSistemaIdioma == idioma.idSistemaIdioma)
                  .firstOrNull,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(context.l10n.errorCargarIdiomas(e.toString())),
    );
  }
}

class _TraduccionCard extends ConsumerStatefulWidget {
  final ClienteTipo clienteTipo;
  final String idIdioma;
  final String nombreIdioma;
  final ClienteTipoIdioma? traduccionExistente;

  const _TraduccionCard({
    required this.clienteTipo,
    required this.idIdioma,
    required this.nombreIdioma,
    required this.traduccionExistente,
  });

  @override
  ConsumerState<_TraduccionCard> createState() => _TraduccionCardState();
}

class _TraduccionCardState extends ConsumerState<_TraduccionCard> {
  late final _nombreController = TextEditingController(text: widget.traduccionExistente?.nombre ?? '');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(clienteTiposRepositoryProvider).guardarTraduccion(
            idConfiguracionClienteTipo: widget.clienteTipo.idConfiguracionClienteTipo,
            idSistemaIdioma: widget.idIdioma,
            nombre: _nombreController.text,
          );
      ref.invalidate(clienteTipoDetailProvider(widget.clienteTipo.idConfiguracionClienteTipo));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.clienteTipoTraduccionGuardadaEnIdioma(widget.nombreIdioma))),
        );
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.clienteTipoNoSePudoGuardar);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.nombreIdioma, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(controller: _nombreController, label: context.l10n.fieldNombre),
            const SizedBox(height: 12),
            AppButton(label: context.l10n.clienteTipoGuardarTraduccion, loading: _loading, onPressed: _guardar),
          ],
        ),
      ),
    );
  }
}
