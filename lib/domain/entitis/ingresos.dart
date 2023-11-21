class Ingreso {
  late final String id;
  final int monto;
  final String mes;
  final String dia;
  final String anio;

  Ingreso(
      {required this.monto,
      required this.dia,
      required this.mes,
      required this.anio});

  factory Ingreso.fromJson(Map<String, dynamic> jsonObject) {
    return Ingreso(
      anio: jsonObject['anio'] as String,
      dia: jsonObject['dia'] as String,
      mes: jsonObject['mes'] as String,
      monto: jsonObject['monto'] as int,
    );
  }

  Map<String, dynamic> toJson() =>
      {'monto': monto, 'dia': dia, 'mes': mes, 'anio': anio};
}
