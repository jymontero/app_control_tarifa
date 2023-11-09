class EstacionGas {
  late final String id;
  final String nombre;
  final String barrio;
  final int valorGalon;

  EstacionGas(
      {required this.nombre, required this.barrio, required this.valorGalon});

  factory EstacionGas.fromJson(Map<String, dynamic> jsonObject) {
    return EstacionGas(
        nombre: jsonObject['nombre'] as String,
        barrio: jsonObject['barrio'] as String,
        valorGalon: jsonObject['valorgalon'] as int);
  }

  Map<String, dynamic> toJson() =>
      {'nombre': nombre, 'barrio': barrio, 'valorgalon': valorGalon};
}
