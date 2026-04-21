class Servicio {
  late final String id;
  final int valorservicio;
  final String hora;
  final String fecha;
  final bool facturada;
  final String tipoServicio;
  final String metodoPago;

  Servicio({
    required this.valorservicio,
    required this.hora,
    required this.fecha,
    required this.facturada,
    this.tipoServicio = 'taxi',
    this.metodoPago = 'efectivo',
  });

  factory Servicio.fromJson(Map<String, dynamic> jsonObject) {
    return Servicio(
      valorservicio: jsonObject['valor'] as int,
      hora: jsonObject['hora'] as String,
      fecha: jsonObject['fecha'] as String,
      facturada: jsonObject['facturada'] as bool,
      tipoServicio: jsonObject['tipoServicio'] as String? ?? 'taxi',
      metodoPago: jsonObject['metodoPago'] as String? ?? 'efectivo',
    );
  }

  Map<String, dynamic> toJson() => {
        'valor': valorservicio,
        'hora': hora,
        'fecha': fecha,
        'facturada': facturada,
        'tipoServicio': tipoServicio,
        'metodoPago': metodoPago,
      };
}
