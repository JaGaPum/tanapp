import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import 'seguidos_screen.dart';

/// La pestaña "Buscar" del menú inferior (tipo -> provincia -> concello -> cliente) es contenido
/// de pestaña, sin ruta propia. Este envoltorio le pone Scaffold + AppBar para poder empujarla
/// como pantalla aparte desde "Seguindo" ("Seguir un cliente nuevo"), igual que ya se hace con
/// "Seguir una zona nueva".
class BuscarClienteScreen extends StatelessWidget {
  const BuscarClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.seguidos)),
      body: const SeguidosScreen(),
    );
  }
}
