class Servicio {
  late final String id;
  final int valorservicio;
  final String hora;
  final String fecha;
  final bool facturada;

  Servicio(
      {required this.valorservicio,
      required this.hora,
      required this.fecha,
      required this.facturada});

  factory Servicio.fromJson(Map<String, dynamic> jsonObject) {
    return Servicio(
        valorservicio: jsonObject['valor'] as int,
        hora: jsonObject['hora'] as String,
        fecha: jsonObject['fecha'] as String,
        facturada: jsonObject['facturada'] as bool);
  }

  Map<String, dynamic> toJson() => {
        'valor': valorservicio,
        'hora': hora,
        'fecha': fecha,
        'facturada': facturada
      };
}
