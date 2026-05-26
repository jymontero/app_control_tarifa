import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/perfil.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

class PerfilProvider with ChangeNotifier {
  final FireStoreDataBase _db = FireStoreDataBase();

  Perfil? _perfil;
  bool _cargando = false;

  Perfil? get perfil => _perfil;
  bool get cargando => _cargando;
  bool get tienePerfil => _perfil != null;

  // Inicial del nombre para el avatar
  String get inicial {
    if (_perfil == null || _perfil!.nombre.isEmpty) return 'J';
    return _perfil!.nombre.substring(0, 1).toUpperCase();
  }

  // Nombre para mostrar en AppBar y Perfil
  String get nombre {
    if (_perfil == null || _perfil!.nombre.isEmpty) return 'Julian';
    return _perfil!.nombre;
  }

  // ── Cargar perfil ─────────────────────────────────────────────────────────────

  Future<void> cargarPerfil() async {
    _cargando = true;
    notifyListeners();

    _perfil = await _db.getPerfil();
    _cargando = false;
    notifyListeners();
  }

  // ── Guardar perfil ────────────────────────────────────────────────────────────

  Future<void> guardarPerfil(Perfil perfil) async {
    await _db.guardarPerfil(perfil);
    _perfil = perfil;
    notifyListeners();
  }
}
