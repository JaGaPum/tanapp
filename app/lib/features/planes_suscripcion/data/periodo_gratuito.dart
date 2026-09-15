/// Un periodo gratuito concreto (080): "Inicio" siempre tiene valor, "Fin" en blanco significa
/// indefinido para este periodo. Puede haber varios a la vez, tanto en la lista general como en
/// la propia de un cliente -los que van caducando se quedan como histórico, no se borran solos-.
class PeriodoGratuito {
  final String id;
  final DateTime inicio;
  final DateTime? fin;

  const PeriodoGratuito({required this.id, required this.inicio, this.fin});

  bool get activo {
    final ahora = DateTime.now();
    return !ahora.isBefore(inicio) && (fin == null || !ahora.isAfter(fin!));
  }

  factory PeriodoGratuito.fromMap(Map<String, dynamic> map, String idField) =>
      PeriodoGratuito(
        id: map[idField] as String,
        inicio: DateTime.parse(map['Inicio'] as String),
        fin: map['Fin'] == null ? null : DateTime.parse(map['Fin'] as String),
      );
}
