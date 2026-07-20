class SolicitudCliente {
  final String idClientesSolicitud;
  final String razonSocial;
  final String nifCif;
  final String nombreContacto;
  final String emailContacto;
  final String telefonoContacto;
  final String? localidad;
  final String? provincia;
  final String? direccion;
  final String? observaciones;
  final String estado;
  final String? observacionesResolucion;
  final DateTime fechaAlta;
  final String? idSistemaUsuarioCliente;
  final String? idConfiguracionClienteTipo;

  const SolicitudCliente({
    required this.idClientesSolicitud,
    required this.razonSocial,
    required this.nifCif,
    required this.nombreContacto,
    required this.emailContacto,
    required this.telefonoContacto,
    this.localidad,
    this.provincia,
    this.direccion,
    this.observaciones,
    required this.estado,
    this.observacionesResolucion,
    required this.fechaAlta,
    this.idSistemaUsuarioCliente,
    this.idConfiguracionClienteTipo,
  });

  bool get tieneUsuarioCliente => idSistemaUsuarioCliente != null;

  factory SolicitudCliente.fromMap(Map<String, dynamic> map) => SolicitudCliente(
        idClientesSolicitud: map['IdClientesSolicitud'] as String,
        razonSocial: map['RazonSocial'] as String,
        nifCif: map['NifCif'] as String,
        nombreContacto: map['NombreContacto'] as String,
        emailContacto: map['EmailContacto'] as String,
        telefonoContacto: map['TelefonoContacto'] as String,
        localidad: map['Localidad'] as String?,
        provincia: map['Provincia'] as String?,
        direccion: map['Direccion'] as String?,
        observaciones: map['Observaciones'] as String?,
        estado: map['Estado'] as String,
        observacionesResolucion: map['ObservacionesResolucion'] as String?,
        fechaAlta: DateTime.parse(map['FechaAlta'] as String),
        idSistemaUsuarioCliente: map['IdSistemaUsuarioCliente'] as String?,
        idConfiguracionClienteTipo: map['IdConfiguracionClienteTipo'] as String?,
      );
}
