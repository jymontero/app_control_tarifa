import 'package:taxi_servicios/domain/entitis/estaciongas.dart';

class GasolineTank {
  final int valor;
  final int kilometraje;
  final double galon;
  EstacionGas? estacionGas;

  GasolineTank(
      {required this.valor,
      required this.kilometraje,
      required this.galon,
      this.estacionGas});
}
