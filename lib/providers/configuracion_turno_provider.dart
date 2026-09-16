import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionTurnoProvider with ChangeNotifier {
  // ── Configuración ──────────────────────────────────────────────────────────

  static const int tiempoAlertaPorDefecto = 60;

  static const List<int> opcionesTiempoAlerta = [
    5,
    10,
    15,
    30,
    45,
    60,
  ];

  static const String _keyTiempoAlertaActividad =
      'turno_tiempo_alerta_actividad';

  int _tiempoAlertaActividad = tiempoAlertaPorDefecto;

  // ── Constructor ────────────────────────────────────────────────────────────

  ConfiguracionTurnoProvider() {
    inicializar();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  int get tiempoAlertaActividad => _tiempoAlertaActividad;

  Duration get duracionAlertaActividad =>
      Duration(minutes: _tiempoAlertaActividad);

  // ── Inicialización ─────────────────────────────────────────────────────────

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();

    final valorGuardado = prefs.getInt(_keyTiempoAlertaActividad);

    if (valorGuardado != null && opcionesTiempoAlerta.contains(valorGuardado)) {
      _tiempoAlertaActividad = valorGuardado;
    } else {
      _tiempoAlertaActividad = tiempoAlertaPorDefecto;
    }

    notifyListeners();
  }

  // ── Actualizar configuración ──────────────────────────────────────────────

  Future<void> actualizarTiempoAlerta(int minutos) async {
    if (!opcionesTiempoAlerta.contains(minutos)) {
      return;
    }

    if (_tiempoAlertaActividad == minutos) {
      return;
    }

    _tiempoAlertaActividad = minutos;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _keyTiempoAlertaActividad,
      minutos,
    );

    notifyListeners();
  }
}
