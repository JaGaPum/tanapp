/// Un documento legal que le aplica a un usuario (según su rol), con si lo aceptó, cuándo, y el
/// texto exacto que aceptó (snapshot, ver 060) — para el detalle "Términos" de la ficha de
/// usuario del admin (a diferencia del Chip resumen "Aceptados"/"Pendientes", aquí se ve
/// documento a documento, y el texto puede haber cambiado desde entonces).
class TerminoAceptacionDetalle {
  final String tipo;

  /// Título del documento tal cual está HOY (para la etiqueta de la fila): puede no coincidir
  /// con [tituloAceptado] si el admin lo ha editado después de que el usuario aceptara.
  final String tituloActual;

  final DateTime? fechaAceptacion;
  final String? tituloAceptado;
  final String? cuerpoAceptado;
  final String? idiomaAceptado;

  const TerminoAceptacionDetalle({
    required this.tipo,
    required this.tituloActual,
    this.fechaAceptacion,
    this.tituloAceptado,
    this.cuerpoAceptado,
    this.idiomaAceptado,
  });

  bool get aceptado => fechaAceptacion != null;

  /// false para aceptaciones de antes de 060 (no se guardaba el texto): no hay forma de
  /// reconstruir qué vio el usuario entonces.
  bool get tieneTextoAceptado => cuerpoAceptado != null;
}
