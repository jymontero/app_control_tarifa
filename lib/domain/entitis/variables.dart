class Variable {
  late final String _id;
  final int valor;
  final String nombre;
  final String? icono;

  Variable({required this.valor, required this.nombre, this.icono});

  String get id => _id;

  set id(String valor) {
    _id = valor;
  }

  factory Variable.fromJson(Map<String, dynamic> jsonObject) {
    return Variable(
        valor: jsonObject['valor'] as int,
        nombre: jsonObject['nombre'] as String,
        icono: jsonObject['icono']);
  }

  Map<String, dynamic> toJson() =>
      {'valor': valor, 'nombre': nombre, 'icono': icono};
}
