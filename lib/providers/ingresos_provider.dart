import 'package:flutter/material.dart';

class IngresosProvider with ChangeNotifier {
  late int _valorIngersoMensual = 0;

  int get valorIngresoMensual => _valorIngersoMensual;

  void setIngresoMensual(int ingreso) {
    _valorIngersoMensual = ingreso;
    notifyListeners();
  }
}
