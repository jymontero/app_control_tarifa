import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';

class ContadorServicioProvider with ChangeNotifier {
  //int _valorMetaRegistrada =
  //  Provider.of<ConfiguracionProvider>(listen: true).metaRegistrada;
  late int _valorMetaObtenida = 0;
  late final int _valorMetaHacer = 270000;
  late final List<Servicio> _listServicesDay = [];

  int _configuracionMetaRegistrada = 0;

  //int get valorMetaRegistrada => _valorMetaRegistrada;
  int get valorMetaObtenida => _valorMetaObtenida;
  int get valorMetaHacer => _valorMetaHacer;
  List get listaServicios => _listServicesDay;
  int get configuracion => _configuracionMetaRegistrada;

  void incrementarMeta(int valorservicio) {
    _valorMetaObtenida += valorservicio;
    notifyListeners();
  }

  void decrementarMeta(int valorservicio) {
    _configuracionMetaRegistrada -= valorservicio;
    notifyListeners();
  }

  void addServicio(Servicio valorServicio) {
    _listServicesDay.add(valorServicio);
    notifyListeners();
  }

  void decrementarGanancia(int valor) {
    _valorMetaObtenida -= valor;
    notifyListeners();
  }

  void setMetaBD(int valor) {
    _configuracionMetaRegistrada = valor;
    notifyListeners();
  }

  void setMetaObtenida() {
    _valorMetaObtenida = 0;
    notifyListeners();
  }

  void setMetaHacer(int valor) {
    _configuracionMetaRegistrada = valor;
    notifyListeners();
  }
}
