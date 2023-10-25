import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
//import 'package:provider/provider.dart';
//import 'package:taxi_servicios/providers/configuracion_provider.dart';
//import 'package:taxi_servicios/providers/configuracion_provider.dart';

class ContadorServicioProvider with ChangeNotifier {
  //int _valorMetaRegistrada =
  //  Provider.of<ConfiguracionProvider>(listen: true).metaRegistrada;
  late int _valorMetaObtenida = 0;
  late final int _valorMetaHacer = 265000;
  late final List<Servicio> _listServicesDay = [];

  late int _configuracionMetaRegistrada =
      ConfiguracionProvider().metaRegistrada;

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
}
