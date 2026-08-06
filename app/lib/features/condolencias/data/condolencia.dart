/// Un mensaje de pésame dejado por un usuario en una esquela.
class Condolencia {
  final String idClientePublicacionCondolencia;
  final String idClientePublicacion;
  final String idSistemaUsuario;
  final String texto;
  final DateTime fechaAlta;
  final String nombreAutor;

  const Condolencia({
    required this.idClientePublicacionCondolencia,
    required this.idClientePublicacion,
    required this.idSistemaUsuario,
    required this.texto,
    required this.fechaAlta,
    required this.nombreAutor,
  });

  factory Condolencia.fromMap(Map<String, dynamic> map) {
    final autor = map['TSistemaUsuarios'] as Map<String, dynamic>;
    final nombre = autor['Nombre'] as String;
    final apellido1 = autor['Apellido1'] as String?;
    return Condolencia(
      idClientePublicacionCondolencia:
          map['IdClientePublicacionCondolencia'] as String,
      idClientePublicacion: map['IdClientePublicacion'] as String,
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      texto: map['Texto'] as String,
      fechaAlta: DateTime.parse(map['FechaAlta'] as String),
      nombreAutor: [
        nombre,
        apellido1,
      ].where((s) => s != null && s.isNotEmpty).join(' '),
    );
  }
}
