class Provincia {
  final String idConfiguracionProvincia;
  final String nombre;
  final String prefijoPostal;

  const Provincia({required this.idConfiguracionProvincia, required this.nombre, required this.prefijoPostal});

  factory Provincia.fromMap(Map<String, dynamic> map) => Provincia(
        idConfiguracionProvincia: map['IdConfiguracionProvincia'] as String,
        nombre: map['Nombre'] as String,
        prefijoPostal: map['PrefijoPostal'] as String,
      );
}
