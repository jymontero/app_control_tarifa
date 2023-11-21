import 'package:taxi_servicios/domain/entitis/estaciongas.dart';

class GasolineTank {
  late final String id;
  final String fecha;
  final String hora;
  final int valor;
  final int kilometraje;
  final double galon;
  EstacionGas? estacionGas;

  GasolineTank(
      {required this.fecha,
      required this.hora,
      required this.valor,
      required this.kilometraje,
      required this.galon,
      this.estacionGas});

  factory GasolineTank.fromJson(Map<String, dynamic> jsonObject) {
    return GasolineTank(
        fecha: jsonObject['fecha'] as String,
        hora: jsonObject['hora'] as String,
        valor: jsonObject['valor'] as int,
        kilometraje: jsonObject['km'] as int,
        galon: jsonObject['galones'] as double);
  }
}
