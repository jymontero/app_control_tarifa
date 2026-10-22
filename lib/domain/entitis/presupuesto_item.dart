class PresupuestoItem {
  late String id;
  final String nombre;
  final int plan;
  final int real;
  final int orden;

  PresupuestoItem({
    required this.nombre,
    required this.plan,
    this.real = 0,
    this.orden = 0,
  });

  // Calculado — nunca se guarda en Firebase
  int get diferencia => plan - real;
  bool get pagado => real > 0;

  factory PresupuestoItem.fromJson(Map<String, dynamic> json) {
    return PresupuestoItem(
      nombre: json['nombre'] as String,
      plan: json['plan'] as int,
      real: json['real'] as int? ?? 0,
      orden: json['orden'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'plan': plan,
        'real': real,
        'orden': orden,
      };
}
