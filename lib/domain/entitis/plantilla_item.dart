class PlantillaItem {
  late String id;
  final String nombre;
  final int planBase;
  final int orden;

  PlantillaItem({
    required this.nombre,
    required this.planBase,
    this.orden = 0,
  });

  factory PlantillaItem.fromJson(Map<String, dynamic> json) {
    return PlantillaItem(
      nombre: json['nombre'] as String,
      planBase: json['planBase'] as int,
      orden: json['orden'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'planBase': planBase,
        'orden': orden,
      };
}
