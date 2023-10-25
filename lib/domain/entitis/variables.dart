class Variable {
  final int valor;
  final String nombre;
  final String? icono;

  Variable({required this.valor, required this.nombre, this.icono});

  Variable.fromJson(Map<String, dynamic> json)
      : valor = json['valor'],
        nombre = json['nombre'],
        icono = json['icono'];

  Map<String, dynamic> toJson() =>
      {'valor': valor, 'nombre': nombre, 'icono': icono};
}
