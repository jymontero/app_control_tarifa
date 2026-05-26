class Perfil {
  late final String id;
  final String nombre;
  final String ciudad;
  final String modeloVehiculo;
  final String placa;

  Perfil({
    required this.nombre,
    required this.ciudad,
    required this.modeloVehiculo,
    required this.placa,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      nombre: json['nombre'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
      modeloVehiculo: json['modeloVehiculo'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'ciudad': ciudad,
        'modeloVehiculo': modeloVehiculo,
        'placa': placa,
      };

  // Copia con campos modificados
  Perfil copyWith({
    String? nombre,
    String? ciudad,
    String? modeloVehiculo,
    String? placa,
  }) {
    return Perfil(
      nombre: nombre ?? this.nombre,
      ciudad: ciudad ?? this.ciudad,
      modeloVehiculo: modeloVehiculo ?? this.modeloVehiculo,
      placa: placa ?? this.placa,
    );
  }
}
