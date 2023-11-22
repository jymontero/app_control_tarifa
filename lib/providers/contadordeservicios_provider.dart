import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';

class ContadorServicioProvider with ChangeNotifier {
  late int _valorMetaObtenida = 0;
  int _configuracionMetaRegistrada = 0;
  int _valorMetaObtenidaFinish = 0;
  late int _numeroSerciosTotal = 0;
  int _valorMetaServiciosLista = 0;

  int get valorMetaObtenida => _valorMetaObtenida;
  int get configuracion => _configuracionMetaRegistrada;
  int get metaObtenidaFinish => _valorMetaObtenidaFinish;
  int get numeroServiciosTotal => _numeroSerciosTotal;
  int get valorMetaObetnidaLista => _valorMetaServiciosLista;
  //late final int _valorMetaHacer = 270000;
//  late final List<Servicio> _listServicesDay = [];

  //int get valorMetaHacer => _valorMetaHacer;
  //List get listaServicios => _listServicesDay;

  ///Se utiliza al iniciar la app.
  void sumarListaServiciosBD(List<Servicio> lista, String modo) {
    int sumar = 0;
    for (var item in lista) {
      int aux = item.valorservicio;
      sumar += aux;
    }
    if (modo == 'HOME') {
      _valorMetaObtenida += sumar;
      _configuracionMetaRegistrada -= sumar;
      notifyListeners();
    } else if (modo == 'FINISH') {
      _valorMetaObtenidaFinish = 0;
      _valorMetaObtenidaFinish += sumar;
      notifyListeners();
    } else if (modo == 'LISTA') {
      _valorMetaServiciosLista = 0;
      _valorMetaServiciosLista += sumar;
      notifyListeners();
    }
  }

  void setNumeroServicios(int numero) {
    _numeroSerciosTotal = numero;
    notifyListeners();
  }

  ///
  void incrementarMetaObtenida(int valorservicio) {
    _valorMetaObtenida += valorservicio;
    notifyListeners();
  }

  ///
  void decrementarMetaObtendia(int valorServicio) {
    _valorMetaObtenida -= valorServicio;
    notifyListeners();
  }

  ///
  void decrementarMetaPorHacer(int valorservicio) {
    _configuracionMetaRegistrada -= valorservicio;
    notifyListeners();
  }

  ///

  void sumarMetaPorHacer(int valor) {
    _configuracionMetaRegistrada += valor;
    notifyListeners();
  }

  ///
  void setMetaHacer(int valor) {
    _configuracionMetaRegistrada = valor;
    notifyListeners();
  }

  ///
  ///Metodo se utliza en finishScreen
  void decrementarMetaObtenidaFinish(int valor) {
    _valorMetaObtenidaFinish -= valor;
    notifyListeners();
  }

  void incrementarMetaObtenidaFinish(int valor) {
    _valorMetaObtenidaFinish += valor;
    notifyListeners();
  }
}
