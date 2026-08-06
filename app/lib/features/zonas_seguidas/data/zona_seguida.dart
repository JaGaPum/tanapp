/// Un concello que el usuario sigue sin tener que seguir a un cliente concreto: recibe los
/// avisos de cualquier cliente con sede en ese concello (ver 038_avisos_por_zona.sql).
class ZonaSeguida {
  final String idSistemaUsuarioZona;
  final String provincia;
  final String concello;

  const ZonaSeguida({
    required this.idSistemaUsuarioZona,
    required this.provincia,
    required this.concello,
  });

  factory ZonaSeguida.fromMap(Map<String, dynamic> map) => ZonaSeguida(
    idSistemaUsuarioZona: map['IdSistemaUsuarioZona'] as String,
    provincia: map['Provincia'] as String,
    concello: map['Concello'] as String,
  );
}
