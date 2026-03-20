import 'package:flutter/material.dart';

class IngresosProvider with ChangeNotifier {
  late int _valorIngersoMensual = 0;
  late int _diasLaborados = 0;

  int get valorIngresoMensual => _valorIngersoMensual;
  int get diasLaborados => _diasLaborados;

  void setIngresoMensual(int ingreso) {
    //print('Dsde ingreso provider');
    //print(ingreso);
    _valorIngersoMensual = ingreso;
    notifyListeners();
  }

  void setDiasLaborados(int dias) {
    _diasLaborados = dias;
    notifyListeners();
  }
}
