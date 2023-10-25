class Servicio {
  final int valorservicio;
  final String hora;
  final String fecha;
  Servicio(
      {required this.valorservicio, required this.hora, required this.fecha});

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
      valorservicio: json['valor'], hora: json['hora'], fecha: json['fecha']);

  Map<String, dynamic> toJson() =>
      {'valor': valorservicio, 'nombre': hora, 'icono': fecha};
}
