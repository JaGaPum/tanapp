import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../data/condolencias_repository.dart';

const _pdfNegro = PdfColor.fromInt(0xFF1A1420);
const _pdfPlum = PdfColor.fromInt(0xFF6B3F55);
const _pdfGris = PdfColors.grey600;

/// Solo visible para el cliente dueño de la publicación (lo decide quien use este widget):
/// genera un PDF con todas las condolencias de la esquela, para poder entregárselo a la
/// familia. Usa el selector nativo de guardar/compartir/imprimir de "printing".
class ExportarCondolenciasButton extends ConsumerStatefulWidget {
  final String idClientePublicacion;
  final String nombreFallecido;

  const ExportarCondolenciasButton({
    super.key,
    required this.idClientePublicacion,
    required this.nombreFallecido,
  });

  @override
  ConsumerState<ExportarCondolenciasButton> createState() =>
      _ExportarCondolenciasButtonState();
}

class _ExportarCondolenciasButtonState
    extends ConsumerState<ExportarCondolenciasButton> {
  bool _generando = false;

  Future<void> _exportar() async {
    // Los textos de l10n se leen ANTES del primer "await": el "context" de los builders de
    // pw.MultiPage/header/footer de más abajo es el de la librería "pdf" (pw.Context), no el
    // de Flutter, así que ahí dentro no se puede usar la extensión "context.l10n".
    final tituloTexto = context.l10n.condolenciasPdfTitulo(
      widget.nombreFallecido,
    );
    final subtituloTexto = context.l10n.condolenciasPdfSubtitulo;
    final vacioTexto = context.l10n.condolenciasVacio;
    final pieTexto = context.l10n.condolenciasPdfPie;

    setState(() => _generando = true);
    try {
      final condolencias = await ref
          .read(condolenciasRepositoryProvider)
          .listTodasCondolencias(widget.idClientePublicacion);
      final doc = pw.Document();

      final tema = pw.ThemeData.withFont(
        base: pw.Font.times(),
        bold: pw.Font.timesBold(),
        italic: pw.Font.timesItalic(),
        boldItalic: pw.Font.timesBoldItalic(),
      );

      doc.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            theme: tema,
            margin: const pw.EdgeInsets.fromLTRB(40, 56, 40, 48),
          ),
          header: (context) {
            if (context.pageNumber != 1) return pw.SizedBox();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _CruzPdf(),
                pw.SizedBox(height: 10),
                pw.Text(
                  tituloTexto,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfNegro,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  subtituloTexto,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                    color: _pdfGris,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Divider(
                  color: _pdfPlum,
                  thickness: 1,
                  indent: 80,
                  endIndent: 80,
                ),
                pw.SizedBox(height: 12),
              ],
            );
          },
          footer: (context) => pw.Column(
            children: [
              pw.Divider(color: _pdfGris, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    pieTexto,
                    style: pw.TextStyle(fontSize: 8, color: _pdfGris),
                  ),
                  pw.Text(
                    '${context.pageNumber} / ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 8, color: _pdfGris),
                  ),
                ],
              ),
            ],
          ),
          build: (context) => [
            if (condolencias.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 24),
                child: pw.Text(
                  vacioTexto,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: _pdfGris,
                  ),
                ),
              ),
            for (final condolencia in condolencias)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.only(left: 14),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: _pdfPlum, width: 2.5),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          condolencia.nombreAutor,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: _pdfNegro,
                          ),
                        ),
                        pw.Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(condolencia.fechaAlta.toLocal()),
                          style: pw.TextStyle(fontSize: 9, color: _pdfGris),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      condolencia.texto,
                      style: pw.TextStyle(
                        fontSize: 12,
                        lineSpacing: 3,
                        color: _pdfNegro,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

      final bytes = await doc.save();
      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'condolencias_${widget.nombreFallecido.replaceAll(' ', '_')}.pdf',
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: _generando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.picture_as_pdf_outlined),
        label: Text(context.l10n.condolenciasDescargarPdf),
        onPressed: _generando ? null : _exportar,
      ),
    );
  }
}

/// Cruz dibujada a mano con dos rectángulos (mismo criterio que CruzIcon en Flutter): los
/// fonts base-14 del PDF (Times) no incluyen el glifo "✝" y lo pintan como un cuadro vacío.
class _CruzPdf extends pw.StatelessWidget {
  _CruzPdf();

  @override
  pw.Widget build(pw.Context context) {
    const alto = 22.0;
    const ancho = 18.0;
    const grosor = 3.2;
    return pw.SizedBox(
      width: ancho,
      height: alto,
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: (ancho - grosor) / 2,
            top: 0,
            child: pw.Container(width: grosor, height: alto, color: _pdfPlum),
          ),
          pw.Positioned(
            left: ancho * 0.15,
            top: alto * 0.22,
            child: pw.Container(
              width: ancho * 0.7,
              height: grosor,
              color: _pdfPlum,
            ),
          ),
        ],
      ),
    );
  }
}
