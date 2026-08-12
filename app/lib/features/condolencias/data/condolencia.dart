/// Un mensaje de pésame dejado por un usuario en una esquela.
class Condolencia {
  final String idClientePublicacionCondolencia;
  final String idClientePublicacion;
  final String idSistemaUsuario;
  final String texto;
  final bool anonima;
  final bool privada;
  final bool moderadaOculta;
  final bool moderadaEditada;
  final DateTime fechaAlta;

  /// Null si es anónima y quien consulta no es ni el propio autor ni ADMIN: la vista
  /// "VClientePublicacionesCondolencias" ya devuelve el nombre oculto en ese caso, así que aquí
  /// solo queda mostrar un texto de "Anónimo" en su lugar.
  final String? nombreAutor;

  const Condolencia({
    required this.idClientePublicacionCondolencia,
    required this.idClientePublicacion,
    required this.idSistemaUsuario,
    required this.texto,
    required this.anonima,
    required this.privada,
    required this.moderadaOculta,
    required this.moderadaEditada,
    required this.fechaAlta,
    required this.nombreAutor,
  });

  factory Condolencia.fromMap(Map<String, dynamic> map) {
    final nombre = map['Nombre'] as String?;
    final apellido1 = map['Apellido1'] as String?;
    final nombreCompleto = [
      nombre,
      apellido1,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    return Condolencia(
      idClientePublicacionCondolencia:
          map['IdClientePublicacionCondolencia'] as String,
      idClientePublicacion: map['IdClientePublicacion'] as String,
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      texto: map['Texto'] as String,
      anonima: map['Anonima'] as bool,
      privada: map['Privada'] as bool,
      moderadaOculta: map['ModeradaOculta'] as bool? ?? false,
      moderadaEditada: map['ModeradaEditada'] as bool? ?? false,
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreAutor: nombreCompleto.isEmpty ? null : nombreCompleto,
    );
  }
}
