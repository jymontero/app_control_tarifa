class MovimientoPresupuesto {
  late String id;
  final String fecha;
  final String hora;
  final String itemNombre;
  final int valor;
  final int realAnterior;
  final int realNuevo;

  MovimientoPresupuesto({
    required this.fecha,
    required this.hora,
    required this.itemNombre,
    required this.valor,
    required this.realAnterior,
    required this.realNuevo,
  });

  factory MovimientoPresupuesto.fromJson(Map<String, dynamic> json) {
    return MovimientoPresupuesto(
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      itemNombre: json['itemNombre'] as String,
      valor: json['valor'] as int,
      realAnterior: json['realAnterior'] as int,
      realNuevo: json['realNuevo'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha,
        'hora': hora,
        'itemNombre': itemNombre,
        'valor': valor,
        'realAnterior': realAnterior,
        'realNuevo': realNuevo,
      };
}
