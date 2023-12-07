class EstacionGas {
  late final String id;
  final String nombre;
  final String barrio;
  final int valorgalon;

  EstacionGas({
    required this.nombre,
    required this.barrio,
    required this.valorgalon,
  });

  factory EstacionGas.fromJson(Map<String, dynamic> jsonObject) {
    return EstacionGas(
        nombre: jsonObject['nombre'] as String,
        barrio: jsonObject['barrio'] as String,
        valorgalon: jsonObject['valorgalon']);
  }

  Map<String, dynamic> toJson() =>
      {'nombre': nombre, 'barrio': barrio, 'valorgalon': valorgalon};
}
