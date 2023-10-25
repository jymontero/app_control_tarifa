// ignore_for_file: avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:taxi_servicios/providers/contadorservicio_provider.dart';

class ServicioTanqueoProvider with ChangeNotifier {
  late String _valorTanqueo = "";
  late String _valorEntrega = "";
  late String _valorLavada = "";
  late String _valorGalones = "";
  late String _valorKilometraje = "";
  late int _valorGanancia = ContadorServicioProvider().valorMetaObtenida;

  String get valorTanqueo => _valorTanqueo;
  String get valorEntrega => _valorEntrega;
  String get valorLavada => _valorLavada;
  String get valorGalones => _valorGalones;
  String get valorKilometros => _valorKilometraje;
  int get valorGanancia => _valorGanancia;

  void setvalorTanqueo(String valor) {
    _valorTanqueo = valor;
    notifyListeners();
  }

  void setvalorEntrega(String valor) {
    _valorEntrega = valor;
    notifyListeners();
  }

  void setvalorLavada(String valor) {
    _valorLavada = valor;
    notifyListeners();
  }

  void setvalorGalones(String valor) {
    _valorGalones = valor;
    notifyListeners();
  }

  void setvalorKilometraje(String valor) {
    _valorKilometraje = valor;
    notifyListeners();
  }

  void setValorGanancia(int valor) {
    _valorGanancia = valor;
    notifyListeners();
  }

  void restarGanancia(int valor) {
    _valorGanancia -= valor;
  }
}
