import 'package:taxi_servicios/domain/entitis/presupuesto_item.dart';

class PresupuestoMensual {
  late String id;
  final String mes;
  final String anio;
  final int ahorroAnterior;
  final int diasPlanificados;
  final List<String> etiquetasContables;
  final String estado; // 'abierto' por defecto
  final int metaDiariaOriginal;

  List<PresupuestoItem> items;

  PresupuestoMensual({
    required this.mes,
    required this.anio,
    this.ahorroAnterior = 0,
    this.diasPlanificados = 0,
    this.etiquetasContables = const [],
    this.items = const [],
    this.estado = 'abierto',
    this.metaDiariaOriginal = 0,
  });
  //Helpers estado
  bool get estaAbierto => estado == 'abierto';
  bool get estaCerrado => estado == 'cerrado';
  // Calculados
  int get totalPlan => items.fold(0, (s, i) => s + i.plan);
  int get totalReal => items.fold(0, (s, i) => s + i.real);
  int get totalACubrir => totalPlan - ahorroAnterior;
  int get metaDiaria =>
      diasPlanificados > 0 ? (totalACubrir / diasPlanificados).ceil() : 0;
  int get ahorroMes => totalPlan - totalReal;
  int desfaseAcumulado({
    required int metaAnterior,
    required int diasTrabajadosHastaHoy,
  }) {
    if (metaDiaria <= metaAnterior) return 0; // no hay desfase
    return (metaDiaria - metaAnterior) * diasTrabajadosHastaHoy;
  }

  int calcularDesfase(int diasTrabajadosHastaHoy) {
    if (metaDiariaOriginal <= 0) return 0;
    if (metaDiaria <= metaDiariaOriginal) return 0;
    return (metaDiaria - metaDiariaOriginal) * diasTrabajadosHastaHoy;
  }

  factory PresupuestoMensual.fromJson(Map<String, dynamic> json) {
    return PresupuestoMensual(
        mes: json['mes'] as String,
        anio: json['anio'] as String,
        ahorroAnterior: json['ahorroAnterior'] as int? ?? 0,
        diasPlanificados: json['diasPlanificados'] as int? ?? 0,
        etiquetasContables:
            List<String>.from(json['etiquetasContables'] as List? ?? []),
        estado: json['estado'] as String? ?? 'abierto',
        metaDiariaOriginal: json['metaDiariaOriginal'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() => {
        'mes': mes,
        'anio': anio,
        'ahorroAnterior': ahorroAnterior,
        'diasPlanificados': diasPlanificados,
        'etiquetasContables': etiquetasContables,
        'estado': estado,
        'metaDiariaOriginal': metaDiariaOriginal,
      };
}
