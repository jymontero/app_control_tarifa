import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
//import 'package:provider/provider.dart';

class ConfiguracionProvider with ChangeNotifier {
  late int _metaRegistrada = 265000;
  late List<Variable> _listVariables = [];
  late final _listaAuxVar = listaVariablesConfiguracion;

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

  set sumarAux(int valor) {
    _metaRegistrada += valor;
    notifyListeners();
  }

  int sumarMeta1() {
    int metaRegistrada2 = 0;
    for (var item in _listaAuxVar) {
      int valor = item['valor'];
      metaRegistrada2 += valor;
    }
    return metaRegistrada2;
  }

  void sumarMeta() {
    _metaRegistrada = sumarMeta1();
    notifyListeners();
  }
}
