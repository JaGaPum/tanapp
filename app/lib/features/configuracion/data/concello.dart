class Concello {
  final String idConfiguracionConcello;
  final String idConfiguracionProvincia;
  final String nombre;

  const Concello({
    required this.idConfiguracionConcello,
    required this.idConfiguracionProvincia,
    required this.nombre,
  });

  factory Concello.fromMap(Map<String, dynamic> map) => Concello(
        idConfiguracionConcello: map['IdConfiguracionConcello'] as String,
        idConfiguracionProvincia: map['IdConfiguracionProvincia'] as String,
        nombre: map['Nombre'] as String,
      );
}
