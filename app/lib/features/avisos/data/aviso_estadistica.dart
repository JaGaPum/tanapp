/// Cuántos seguidores recibieron un aviso enviado y cuántos ya lo han leído, para la gráfica
/// del Panel de Datos del cliente.
class AvisoEstadistica {
  final String idClienteAviso;
  final String titulo;
  final DateTime fechaAlta;
  final int recibidos;
  final int leidos;

  const AvisoEstadistica({
    required this.idClienteAviso,
    required this.titulo,
    required this.fechaAlta,
    required this.recibidos,
    required this.leidos,
  });
}
