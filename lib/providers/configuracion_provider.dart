import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
//import 'package:provider/provider.dart';

class ConfiguracionProvider with ChangeNotifier {
  final int _metaRegistrada = 265000;
  final List<Variable> _listVariables = [];

  int get metaRegistrada => _metaRegistrada;
  List get listaVariables => _listVariables;

  void addVariable(Variable variable) {
    _listVariables.add(variable);
    notifyListeners();
  }
}
