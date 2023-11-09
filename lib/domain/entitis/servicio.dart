class Servicio {
  late final String _id;
  final int valorservicio;
  final String hora;
  final String fecha;

  Servicio(
      {required this.valorservicio, required this.hora, required this.fecha});

  String get id => _id;

  set id(String valor) {
    _id = valor;
  }

  factory Servicio.fromJson(Map<String, dynamic> jsonObject) {
    return Servicio(
        valorservicio: jsonObject['valor'] as int,
        hora: jsonObject['hora'] as String,
        fecha: jsonObject['fecha'] as String);
  }

  Map<String, dynamic> toJson() =>
      {'valor': valorservicio, 'hora': hora, 'fecha': fecha};
}
