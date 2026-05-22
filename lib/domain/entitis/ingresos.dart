class Ingreso {
  late final String id;
  final int monto;
  final String mes;
  final String dia;
  final String anio;
  final int totalBruto; // total bruto de servicios del día
  final int deducciones; // tanqueo + entrega + lavada
  final int numServicios; // NEW: número de servicios del día

  Ingreso({
    required this.monto,
    required this.dia,
    required this.mes,
    required this.anio,
    this.totalBruto = 0, // valor por defecto para registros viejos
    this.deducciones = 0,
    this.numServicios = 0,
  });

  factory Ingreso.fromJson(Map<String, dynamic> jsonObject) {
    return Ingreso(
      anio: jsonObject['anio'] as String,
      dia: jsonObject['dia'] as String,
      mes: jsonObject['mes'] as String,
      monto: jsonObject['monto'] as int,
      totalBruto: jsonObject['totalBruto'] as int? ?? 0,
      deducciones: jsonObject['deducciones'] as int? ?? 0,
      numServicios: jsonObject['numServicios'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'monto': monto,
        'dia': dia,
        'mes': mes,
        'anio': anio,
        'totalBruto': totalBruto,
        'deducciones': deducciones,
        'numServicios': numServicios,
      };
}
