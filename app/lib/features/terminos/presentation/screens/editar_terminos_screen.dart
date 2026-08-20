import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../application/terminos_providers.dart';
import '../../data/termino_documento.dart';
import '../../data/terminos_repository.dart';

String _nombreTipo(BuildContext context, String tipo) => switch (tipo) {
  'TERMINOS_USO' => context.l10n.terminosTipoUso,
  'PRIVACIDAD' => context.l10n.terminosTipoPrivacidad,
  _ => tipo,
};

String _nombreRol(BuildContext context, String rol) => switch (rol) {
  'CLIENTE' => context.l10n.terminosRolCliente,
  'USUARIO_ORDINARIO' => context.l10n.terminosRolUsuarioOrdinario,
  _ => rol,
};

/// Admin: editar el título/cuerpo de los términos de uso y la política de privacidad, en cada
/// idioma. Edita el contenido de la versión activa en el sitio (no crea una versión nueva ni
/// obliga a los usuarios que ya aceptaron a volver a hacerlo).
class EditarTerminosScreen extends ConsumerWidget {
  const EditarTerminosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentosAsync = ref.watch(terminosDocumentosEditablesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.usuarioTerminosTitulo)),
      body: documentosAsync.when(
        data: (documentos) => ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            for (final documento in documentos) ...[
              Text(
                '${_nombreTipo(context, documento.tipo)} · '
                '${_nombreRol(context, documento.rol)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final idioma in documento.idiomas) ...[
                _IdiomaEditor(
                  idSistemaTermino: documento.idSistemaTermino,
                  idioma: idioma,
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorGenerico(e.toString()))),
      ),
    );
  }
}

class _IdiomaEditor extends ConsumerStatefulWidget {
  final String idSistemaTermino;
  final TerminoIdiomaContenido idioma;
  const _IdiomaEditor({required this.idSistemaTermino, required this.idioma});

  @override
  ConsumerState<_IdiomaEditor> createState() => _IdiomaEditorState();
}

class _IdiomaEditorState extends ConsumerState<_IdiomaEditor> {
  late final _tituloController = TextEditingController(
    text: widget.idioma.titulo,
  );
  late final _cuerpoController = TextEditingController(
    text: widget.idioma.cuerpo,
  );
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tituloController.dispose();
    _cuerpoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(terminosRepositoryProvider)
          .guardarContenido(
            idSistemaTermino: widget.idSistemaTermino,
            idSistemaIdioma: widget.idioma.idSistemaIdioma,
            titulo: _tituloController.text,
            cuerpo: _cuerpoController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.terminosContenidoGuardadoEnIdioma(
                widget.idioma.nombreIdioma,
              ),
            ),
          ),
        );
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.idioma.nombreIdioma,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            if (_error != null) ErrorBanner(message: _error!),
            AppTextField(
              controller: _tituloController,
              label: context.l10n.terminosCampoTitulo,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _cuerpoController,
              label: context.l10n.terminosCampoCuerpo,
              maxLines: 12,
            ),
            const SizedBox(height: 12),
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
