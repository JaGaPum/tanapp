import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../application/importacion_web_providers.dart';
import '../../data/cliente_importacion_web.dart';
import '../../data/importacion_web_repository.dart';

class ConfigurarImportacionWebScreen extends ConsumerWidget {
  const ConfigurarImportacionWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(miImportacionWebProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importacionWebTitulo)),
      body: configAsync.when(
        data: (config) => _ImportacionWebBody(config: config),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _ImportacionWebBody extends ConsumerStatefulWidget {
  final ClienteImportacionWeb? config;
  const _ImportacionWebBody({required this.config});

  @override
  ConsumerState<_ImportacionWebBody> createState() => _ImportacionWebBodyState();
}

class _ImportacionWebBodyState extends ConsumerState<_ImportacionWebBody> {
  final _formKey = GlobalKey<FormState>();
  late final _urlController = TextEditingController(text: widget.config?.url ?? '');
  late bool _aceptado = widget.config?.activo ?? false;
  bool _guardando = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _validarUrl(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty || !(texto.startsWith('http://') || texto.startsWith('https://'))) {
      return context.l10n.importacionWebUrlInvalida;
    }
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || !_aceptado) return;
    setState(() => _guardando = true);
    try {
      await ref.read(importacionWebRepositoryProvider).guardar(_urlController.text.trim());
      ref.invalidate(miImportacionWebProvider);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _desactivar() async {
    setState(() => _guardando = true);
    try {
      await ref.read(importacionWebRepositoryProvider).desactivar();
      ref.invalidate(miImportacionWebProvider);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (config != null) ...[
            Text(
              config.activo
                  ? context.l10n.importacionWebActiva(DateFormat('dd/MM/yyyy').format(config.fechaAutorizacion))
                  : context.l10n.importacionWebDesactivada,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: config.activo ? Colors.green : Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          Text(context.l10n.importacionWebConsentimiento),
          const SizedBox(height: 16),
          AppTextField(
            controller: _urlController,
            label: context.l10n.importacionWebUrlLabel,
            hint: 'https://...',
            keyboardType: TextInputType.url,
            validator: _validarUrl,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _aceptado,
            title: Text(context.l10n.importacionWebAceptoCheckbox),
            onChanged: (marcado) => setState(() => _aceptado = marcado ?? false),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: config == null ? context.l10n.importacionWebGuardar : context.l10n.importacionWebActualizar,
            loading: _guardando,
            onPressed: _aceptado ? _guardar : null,
          ),
          if (config != null && config.activo) ...[
            const SizedBox(height: 12),
            AppButton(
              label: context.l10n.importacionWebDesactivar,
              secondary: true,
              loading: _guardando,
              onPressed: _desactivar,
            ),
          ],
        ],
      ),
    );
  }
}
