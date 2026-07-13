import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../comunicaciones/application/comunicaciones_providers.dart';
import '../../../comunicaciones/data/comunicacion.dart';
import '../../../comunicaciones/data/comunicaciones_repository.dart';
import '../../../sistema_usuarios/data/catalogos_repository.dart';

const _tiposComunicacion = ['EMAIL', 'MENSAJE', 'NOTIFICACION'];

class ComunicacionDetailScreen extends ConsumerWidget {
  final String? idConfiguracionComunicacion;
  const ComunicacionDetailScreen({super.key, this.idConfiguracionComunicacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = idConfiguracionComunicacion;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.comunicacionNueva)),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Center(child: _ComunicacionForm(comunicacion: null)),
        ),
      );
    }

    final comunicacionAsync = ref.watch(comunicacionDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.comunicacionEditar)),
      body: comunicacionAsync.when(
        data: (comunicacion) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(child: _ComunicacionForm(comunicacion: comunicacion)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _ComunicacionForm extends ConsumerStatefulWidget {
  final Comunicacion? comunicacion;
  const _ComunicacionForm({required this.comunicacion});

  @override
  ConsumerState<_ComunicacionForm> createState() => _ComunicacionFormState();
}

class _ComunicacionFormState extends ConsumerState<_ComunicacionForm> {
  final _formKey = GlobalKey<FormState>();
  late final _codController = TextEditingController(text: widget.comunicacion?.codComunicacion ?? '');
  late final _nombreController = TextEditingController(text: widget.comunicacion?.nombreComunicacion ?? '');
  late final _remitenteController = TextEditingController(text: widget.comunicacion?.remitente ?? '');
  late String _tipo = widget.comunicacion?.tipoComunicacion ?? _tiposComunicacion.first;
  late bool _activo = widget.comunicacion?.activo ?? true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codController.dispose();
    _nombreController.dispose();
    _remitenteController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(comunicacionesRepositoryProvider);
    try {
      if (widget.comunicacion == null) {
        final nuevoId = await repo.crearComunicacion(
          tipoComunicacion: _tipo,
          codComunicacion: _codController.text,
          nombreComunicacion: _nombreController.text,
          remitente: _remitenteController.text,
          activo: _activo,
        );
        ref.invalidate(comunicacionesListProvider);
        if (mounted) context.pushReplacement('/admin/configuracion/comunicaciones/$nuevoId');
      } else {
        await repo.actualizarComunicacion(
          idConfiguracionComunicacion: widget.comunicacion!.idConfiguracionComunicacion,
          tipoComunicacion: _tipo,
          codComunicacion: _codController.text,
          nombreComunicacion: _nombreController.text,
          remitente: _remitenteController.text,
          activo: _activo,
        );
        ref.invalidate(comunicacionesListProvider);
        ref.invalidate(comunicacionDetailProvider(widget.comunicacion!.idConfiguracionComunicacion));
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
                DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: InputDecoration(labelText: context.l10n.comunicacionTipo),
                  items: _tiposComunicacion.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (value) => setState(() => _tipo = value ?? _tipo),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _codController,
                  label: context.l10n.comunicacionCodigo,
                  validator: Validators.required(context, context.l10n.comunicacionCodigo),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nombreController,
                  label: context.l10n.fieldNombre,
                  validator: Validators.required(context, context.l10n.fieldNombre),
                ),
                const SizedBox(height: 16),
                AppTextField(controller: _remitenteController, label: context.l10n.comunicacionRemitente),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(context.l10n.comunicacionActiva),
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                AppButton(label: context.l10n.guardar, loading: _loading, onPressed: _guardar),
              ],
            ),
          ),
          if (widget.comunicacion != null) ...[
            const SizedBox(height: 40),
            Text(
              context.l10n.comunicacionTextosPorIdioma,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _TraduccionesSection(comunicacion: widget.comunicacion!),
          ],
        ],
      ),
    );
  }
}

class _TraduccionesSection extends ConsumerWidget {
  final Comunicacion comunicacion;
  const _TraduccionesSection({required this.comunicacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idiomasAsync = ref.watch(idiomasCatalogoProvider);
    return idiomasAsync.when(
      data: (idiomas) => Column(
        children: [
          for (final idioma in idiomas) ...[
            _TraduccionCard(
              comunicacion: comunicacion,
              idIdioma: idioma.idSistemaIdioma,
              nombreIdioma: idioma.nombre,
              traduccionExistente: comunicacion.traducciones
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
  final Comunicacion comunicacion;
  final String idIdioma;
  final String nombreIdioma;
  final ComunicacionIdioma? traduccionExistente;

  const _TraduccionCard({
    required this.comunicacion,
    required this.idIdioma,
    required this.nombreIdioma,
    required this.traduccionExistente,
  });

  @override
  ConsumerState<_TraduccionCard> createState() => _TraduccionCardState();
}

class _TraduccionCardState extends ConsumerState<_TraduccionCard> {
  late final _asuntoController = TextEditingController(text: widget.traduccionExistente?.asunto ?? '');
  late final _cuerpoController = TextEditingController(text: widget.traduccionExistente?.cuerpo ?? '');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _asuntoController.dispose();
    _cuerpoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(comunicacionesRepositoryProvider).guardarTraduccion(
            idConfiguracionComunicacion: widget.comunicacion.idConfiguracionComunicacion,
            idSistemaIdioma: widget.idIdioma,
            asunto: _asuntoController.text,
            cuerpo: _cuerpoController.text,
          );
      ref.invalidate(comunicacionDetailProvider(widget.comunicacion.idConfiguracionComunicacion));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.comunicacionTextoGuardadoEnIdioma(widget.nombreIdioma))),
        );
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.comunicacionNoSePudoGuardar);
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
            AppTextField(controller: _asuntoController, label: context.l10n.comunicacionAsunto),
            const SizedBox(height: 12),
            AppTextField(controller: _cuerpoController, label: context.l10n.comunicacionCuerpo, maxLines: 5),
            const SizedBox(height: 12),
            AppButton(label: context.l10n.comunicacionGuardarTexto, loading: _loading, onPressed: _guardar),
          ],
        ),
      ),
    );
  }
}
