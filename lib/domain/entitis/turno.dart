class Turno {
  late String id;
  final String fecha; // formato: '2026-08-20'
  final String etiquetaId;
  final String etiquetaNombre;
  final String etiquetaColor;
  final bool confirmado; // true cuando hay ingreso registrado ese día

  Turno({
    required this.fecha,
    required this.etiquetaId,
    required this.etiquetaNombre,
    required this.etiquetaColor,
    this.confirmado = false,
  });

  factory Turno.fromJson(Map<String, dynamic> json) {
    return Turno(
      fecha: json['fecha'] as String,
      etiquetaId: json['etiquetaId'] as String,
      etiquetaNombre: json['etiquetaNombre'] as String,
      etiquetaColor: json['etiquetaColor'] as String,
      confirmado: json['confirmado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha,
        'etiquetaId': etiquetaId,
        'etiquetaNombre': etiquetaNombre,
        'etiquetaColor': etiquetaColor,
        'confirmado': confirmado,
      };

  // Convierte el color hex a Color de Flutter
  // Uso: Color(turno.colorValue)
  int get colorValue {
    final hex = etiquetaColor.replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }
}
