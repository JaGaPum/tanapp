class ActoTipo {
  final String idConfiguracionActoTipo;
  final String nombre;
  final bool activo;

  const ActoTipo({
    required this.idConfiguracionActoTipo,
    required this.nombre,
    required this.activo,
  });

  factory ActoTipo.fromMap(Map<String, dynamic> map) => ActoTipo(
    idConfiguracionActoTipo: map['IdConfiguracionActoTipo'] as String,
    nombre: map['Nombre'] as String,
    activo: map['Activo'] as bool? ?? true,
  );
}
