/// Campos que devuelve la Edge Function "escanear-esquela-imagen" (Claude con visión) al
/// escanear la foto de una esquela, en el mismo formato que ya usa el formulario manual.
class EsquelaEscaneada {
  final String nombreFallecido;
  final String? fechaFallecimiento;
  final int? edad;
  final String? fechaFuneral;
  final String? horaFuneral;
  final String? iglesia;
  final String? lugar;
  final String? capillaArdiente;
  final String? sala;
  final String? observaciones;

  const EsquelaEscaneada({
    required this.nombreFallecido,
    required this.fechaFallecimiento,
    required this.edad,
    required this.fechaFuneral,
    required this.horaFuneral,
    required this.iglesia,
    required this.lugar,
    required this.capillaArdiente,
    required this.sala,
    required this.observaciones,
  });

  factory EsquelaEscaneada.fromMap(Map<String, dynamic> map) =>
      EsquelaEscaneada(
        nombreFallecido: map['nombreFallecido'] as String,
        fechaFallecimiento: map['fechaFallecimiento'] as String?,
        edad: map['edad'] as int?,
        fechaFuneral: map['fechaFuneral'] as String?,
        horaFuneral: map['horaFuneral'] as String?,
        iglesia: map['iglesia'] as String?,
        lugar: map['lugar'] as String?,
        capillaArdiente: map['capillaArdiente'] as String?,
        sala: map['sala'] as String?,
        observaciones: map['observaciones'] as String?,
      );
}
