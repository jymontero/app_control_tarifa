import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

class ConfiguracionProvider with ChangeNotifier {
  FireStoreDataBase db = FireStoreDataBase();
  late int _metaRegistrada = 265000;
  late List<Variable> _listVariables = [];
  late int _metaRegistradaBD = 0;

  int get metaRegistrada => _metaRegistrada;
  List get listaVariables => _listVariables;
  int get metaRegistradaBD => _metaRegistradaBD;

  set dataFromBD(List<Variable> listaVariables) {
    _listVariables = listaVariables;
  }

  void setMetaRegistradaBD(int valor) {
    _metaRegistradaBD = valor;
    notifyListeners();
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

  ///
  void sumarListaBd(List<Variable> lista) {
    _listVariables = lista;

    int sumar = 0;
    for (var item in _listVariables) {
      int aux = item.valor;
      sumar += aux;
    }
    _metaRegistradaBD = sumar;
    notifyListeners();
  }

//
  void sumarVariable(int valor) {
    _metaRegistradaBD += valor;
    notifyListeners();
  }

  ///
  void restaVariable(int valor) {
    _metaRegistradaBD -= valor;
    notifyListeners();
  }
}
