class Etiqueta {
  late String id;
  final String nombre;
  final String color; // hex color ej: '#F5C518'

  Etiqueta({
    required this.nombre,
    required this.color,
  });

  factory Etiqueta.fromJson(Map<String, dynamic> json) {
    return Etiqueta(
      nombre: json['nombre'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'color': color,
      };
}
