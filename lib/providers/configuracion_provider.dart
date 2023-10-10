import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
//import 'package:provider/provider.dart';

class ConfiguracionProvider with ChangeNotifier {
  late int _metaRegistrada = 265000;
  late List<Variable> _listVariables = [];

  int get metaRegistrada => _metaRegistrada;
  List get listaVariables => _listVariables;

  set dataFromBD(List<Variable> listaVariables) {
    _listVariables = listaVariables;
  }

  void addVariable(Variable variable) {
    _listVariables.add(variable);
    notifyListeners();
  }

  void sumaMetaRegistrada() {
    for (var item in _listVariables) {
      _metaRegistrada += item.valor;
    }
    notifyListeners();
  }
}
