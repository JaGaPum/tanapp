class RolAsignado {
  final String idSistemaUsuarioRol;
  final String idSistemaRol;
  final String codigo;
  final String nombre;

  const RolAsignado({
    required this.idSistemaUsuarioRol,
    required this.idSistemaRol,
    required this.codigo,
    required this.nombre,
  });
}

class UsuarioPerfil {
  final String idSistemaUsuario;
  final String idAuthSupabase;
  final String email;
  final String nombre;
  final String? apellido1;
  final String? apellido2;
  final String? telefono;
  final String? concello;
  final String? provincia;
  final String? fotoUrl;
  final String? idSistemaIdiomaPreferido;
  final bool activo;
  final bool emailConfirmado;
  final List<RolAsignado> rolesAsignados;

  const UsuarioPerfil({
    required this.idSistemaUsuario,
    required this.idAuthSupabase,
    required this.email,
    required this.nombre,
    this.apellido1,
    this.apellido2,
    this.telefono,
    this.concello,
    this.provincia,
    this.fotoUrl,
    this.idSistemaIdiomaPreferido,
    required this.activo,
    required this.emailConfirmado,
    required this.rolesAsignados,
  });

  List<String> get roles => rolesAsignados.map((r) => r.codigo).toList();

  String get nombreCompleto =>
      [nombre, apellido1, apellido2].where((s) => s != null && s.trim().isNotEmpty).join(' ');

  factory UsuarioPerfil.fromMap(Map<String, dynamic> map) {
    final rolesRaw = map['TSistemaUsuariosRoles'] as List<dynamic>? ?? const [];
    final roles = rolesRaw
        .map((r) => r as Map<String, dynamic>)
        .where((r) => r['TSistemaRoles'] != null)
        .map((r) {
          final rolInfo = r['TSistemaRoles'] as Map<String, dynamic>;
          return RolAsignado(
            idSistemaUsuarioRol: r['IdSistemaUsuarioRol'] as String,
            idSistemaRol: r['IdSistemaRol'] as String,
            codigo: rolInfo['Codigo'] as String,
            nombre: rolInfo['Nombre'] as String,
          );
        })
        .toList();

    return UsuarioPerfil(
      idSistemaUsuario: map['IdSistemaUsuario'] as String,
      idAuthSupabase: map['IdAuthSupabase'] as String,
      email: map['Email'] as String,
      nombre: map['Nombre'] as String,
      apellido1: map['Apellido1'] as String?,
      apellido2: map['Apellido2'] as String?,
      telefono: map['Telefono'] as String?,
      concello: map['Concello'] as String?,
      provincia: map['Provincia'] as String?,
      fotoUrl: map['FotoUrl'] as String?,
      idSistemaIdiomaPreferido: map['IdSistemaIdiomaPreferido'] as String?,
      activo: map['Activo'] as bool? ?? true,
      emailConfirmado: map['EmailConfirmado'] as bool? ?? false,
      rolesAsignados: roles,
    );
  }
}
