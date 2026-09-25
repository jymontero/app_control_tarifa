import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  late final String id;
  final int valorservicio;
  final String hora;
  final String fecha;
  final bool facturada;
  final String tipoServicio;
  final String metodoPago;
  // ── Campos tracking ───────────────────────────────────────────────────────────
  final double kmRecorridos;
  final String nombreInicio;
  final String nombreFin;
  final GeoPoint? puntoInicio;
  final GeoPoint? puntoFin;
  final List<GeoPoint> rutaPuntos;

  Servicio({
    required this.valorservicio,
    required this.hora,
    required this.fecha,
    required this.facturada,
    this.tipoServicio = 'taxi',
    this.metodoPago = 'efectivo',
    this.kmRecorridos = 0,
    this.nombreInicio = '',
    this.nombreFin = '',
    this.puntoInicio,
    this.puntoFin,
    this.rutaPuntos = const [],
  });

  factory Servicio.fromJson(Map<String, dynamic> jsonObject) {
    // Parsear lista de GeoPoints para la ruta
    List<GeoPoint> ruta = [];
    if (jsonObject['rutaPuntos'] != null) {
      final lista = jsonObject['rutaPuntos'] as List<dynamic>;
      ruta = lista.whereType<GeoPoint>().toList();
    }
    return Servicio(
      valorservicio: jsonObject['valor'] as int,
      hora: jsonObject['hora'] as String,
      fecha: jsonObject['fecha'] as String,
      facturada: jsonObject['facturada'] as bool,
      tipoServicio: jsonObject['tipoServicio'] as String? ?? 'taxi',
      metodoPago: jsonObject['metodoPago'] as String? ?? 'efectivo',
      kmRecorridos: (jsonObject['kmRecorridos'] as num?)?.toDouble() ?? 0,
      nombreInicio: jsonObject['nombreInicio'] as String? ?? '',
      nombreFin: jsonObject['nombreFin'] as String? ?? '',
      puntoInicio: jsonObject['puntoInicio'] as GeoPoint?,
      puntoFin: jsonObject['puntoFin'] as GeoPoint?,
      rutaPuntos: ruta,
    );
  }

  Map<String, dynamic> toJson() => {
        'valor': valorservicio,
        'hora': hora,
        'fecha': fecha,
        'facturada': facturada,
        'tipoServicio': tipoServicio,
        'metodoPago': metodoPago,
        'kmRecorridos': kmRecorridos,
        'nombreInicio': nombreInicio,
        'nombreFin': nombreFin,
        'puntoInicio': puntoInicio,
        'puntoFin': puntoFin,
        'rutaPuntos': rutaPuntos,
      };

  // ── Helper — sabe si tiene datos de tracking ──────────────────────────────────
  bool get tieneTracking => kmRecorridos > 0 || rutaPuntos.isNotEmpty;
}
