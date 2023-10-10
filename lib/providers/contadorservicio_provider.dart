import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
//import 'package:provider/provider.dart';
//import 'package:taxi_servicios/providers/configuracion_provider.dart';
//import 'package:taxi_servicios/providers/configuracion_provider.dart';

class ContadorServicioProvider with ChangeNotifier {
  //int _valorMetaRegistrada =
  //  Provider.of<ConfiguracionProvider>(listen: true).metaRegistrada;
  int _valorMetaObtenida = 0;
  final int _valorMetaHacer = 265000;
  final List<Servicio> _listServicesDay = [];
  int _configuracion = ConfiguracionProvider().metaRegistrada;

  //int get valorMetaRegistrada => _valorMetaRegistrada;
  int get valorMetaObtenida => _valorMetaObtenida;
  int get valorMetaHacer => _valorMetaHacer;
  List get listaServicios => _listServicesDay;
  int get configuracion => _configuracion;

  void incrementarMeta(int valorservicio) {
    _valorMetaObtenida += valorservicio;
    notifyListeners();
  }

  void decrementarMeta(int valorservicio) {
    _configuracion -= valorservicio;
    notifyListeners();
  }

  void addServicio(Servicio valorServicio) {
    _listServicesDay.add(valorServicio);
    notifyListeners();
  }
}
