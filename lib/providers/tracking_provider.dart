import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_servicios/services/location_service.dart';
import 'package:taxi_servicios/services/geocoding_service.dart';

// ── Estados del tracking ──────────────────────────────────────────────────────
enum EstadoTracking { inactivo, activo, finalizado }

class TrackingProvider with ChangeNotifier, WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  // ── Estado ────────────────────────────────────────────────────────────────────
  EstadoTracking _estado = EstadoTracking.inactivo;
  List<LatLng> _puntos = [];
  double _kmRecorridos = 0;
  int _segundos = 0;
  LatLng? _puntoInicio;
  LatLng? _puntoFin;
  String _nombreInicio = '';
  String _nombreFin = '';
  bool _cargando = false;

  // ── Timers independientes — SRP ───────────────────────────────────────────────
  Timer? _timerGPS; // captura GPS cada 5 segundos
  Timer? _timerStorage; // guarda en SharedPreferences cada 30 segundos
  Timer? _timerCronometro; // actualiza segundos cada 1 segundo

  // ── Getters ───────────────────────────────────────────────────────────────────
  EstadoTracking get estado => _estado;
  List<LatLng> get puntos => _puntos;
  double get kmRecorridos => _kmRecorridos;
  int get segundos => _segundos;
  LatLng? get puntoInicio => _puntoInicio;
  LatLng? get puntoFin => _puntoFin;
  String get nombreInicio => _nombreInicio;
  String get nombreFin => _nombreFin;
  bool get cargando => _cargando;
  bool get activo => _estado == EstadoTracking.activo;
  bool get hayRecorrido => _puntos.isNotEmpty;

  String get tiempoFormateado {
    final m = _segundos ~/ 60;
    final s = _segundos % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Velocidad aproximada en km/h
  double get velocidadActual {
    if (_puntos.length < 2) return 0;
    final distancia = _locationService.calcularDistanciaMetros(
      _puntos[_puntos.length - 2],
      _puntos.last,
    );
    // distancia en 5 segundos → km/h
    return (distancia / 5) * 3.6;
  }

  // ── Inicializar ───────────────────────────────────────────────────────────────

  Future<void> inicializar() async {
    WidgetsBinding.instance.addObserver(this);
    await _verificarRecorridoPendiente();
  }

  // ── App lifecycle — WidgetsBindingObserver ────────────────────────────────────
  // Detecta cuando la app va a segundo plano o vuelve al frente

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && activo) {
      // App va a segundo plano — guarda inmediatamente
      _guardarEnStorage();
    } else if (state == AppLifecycleState.resumed && activo) {
      // App vuelve al frente — continúa normal
      notifyListeners();
    }
  }

  // ── Iniciar tracking ──────────────────────────────────────────────────────────

  Future<bool> iniciarTracking() async {
    _cargando = true;
    notifyListeners();

    // Verificar permisos
    final tienePermisos = await _locationService.verificarPermisos();
    if (!tienePermisos) {
      _cargando = false;
      notifyListeners();
      return false;
    }

    // Obtener posición inicial
    final posicionInicial = await _locationService.obtenerPosicionActual();
    if (posicionInicial == null) {
      _cargando = false;
      notifyListeners();
      return false;
    }

    // Inicializar estado
    _puntos = [posicionInicial];
    _puntoInicio = posicionInicial;
    _kmRecorridos = 0;
    _segundos = 0;
    _estado = EstadoTracking.activo;

    // Obtener nombre del lugar de inicio
    _nombreInicio = await _geocodingService.obtenerNombreLugar(posicionInicial);

    // Iniciar los dos timers independientes
    _iniciarTimerGPS();
    _iniciarTimerStorage();
    _iniciarCronometro();

    _cargando = false;
    notifyListeners();
    return true;
  }

  // ── Finalizar tracking ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> finalizarTracking() async {
    // Detener timers
    _detenerTimers();

    // Obtener posición final
    final posicionFinal = await _locationService.obtenerPosicionActual();
    if (posicionFinal != null) {
      _puntos.add(posicionFinal);
      _puntoFin = posicionFinal;
      _nombreFin = await _geocodingService.obtenerNombreLugar(posicionFinal);
      _kmRecorridos = _locationService.metrosAKm(
        _locationService.calcularDistanciaTotal(_puntos),
      );
    }

    _estado = EstadoTracking.finalizado;

    // Limpiar SharedPreferences
    await _limpiarStorage();

    // Retornar datos para el formulario de registro
    final datos = {
      'puntos': _puntos,
      'kmRecorridos': _kmRecorridos,
      'puntoInicio': _puntoInicio,
      'puntoFin': _puntoFin,
      'nombreInicio': _nombreInicio,
      'nombreFin': _nombreFin,
      'segundos': _segundos,
    };

    notifyListeners();
    return datos;
  }

  // ── Recuperar recorrido pendiente ─────────────────────────────────────────────

  Future<bool> hayRecorridoPendiente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tracking_activo') ?? false;
  }

  Future<Map<String, dynamic>?> obtenerRecorridoPendiente() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('tracking_activo') ?? false)) return null;

    final puntosJson = prefs.getStringList('tracking_puntos') ?? [];
    final puntos = puntosJson.map((p) {
      final coords = p.split(',');
      return LatLng(double.parse(coords[0]), double.parse(coords[1]));
    }).toList();

    return {
      'puntos': puntos,
      'kmRecorridos': prefs.getDouble('tracking_km') ?? 0,
      'nombreInicio': prefs.getString('tracking_nombre_inicio') ?? '',
      'segundos': prefs.getInt('tracking_segundos') ?? 0,
    };
  }

  Future<void> continuarRecorrido(Map<String, dynamic> datos) async {
    _puntos = datos['puntos'] as List<LatLng>;
    _kmRecorridos = datos['kmRecorridos'] as double;
    _nombreInicio = datos['nombreInicio'] as String;
    _segundos = datos['segundos'] as int;
    _puntoInicio = _puntos.isNotEmpty ? _puntos.first : null;
    _estado = EstadoTracking.activo;

    _iniciarTimerGPS();
    _iniciarTimerStorage();
    _iniciarCronometro();
    notifyListeners();
  }

  Future<void> descartarRecorrido() async {
    _detenerTimers();
    await _limpiarStorage();
    _resetear();
    notifyListeners();
  }

  // ── Timers ────────────────────────────────────────────────────────────────────

  void _iniciarTimerGPS() {
    _timerGPS = Timer.periodic(const Duration(seconds: 5), (_) async {
      final posicion = await _locationService.obtenerPosicionActual();
      if (posicion == null) return;

      // Solo agregar si se movió más de 10 metros (filtra ruido GPS)
      if (_puntos.isNotEmpty) {
        final distancia =
            _locationService.calcularDistanciaMetros(_puntos.last, posicion);
        if (distancia < 10) return;
      }

      _puntos.add(posicion);
      _kmRecorridos = _locationService.metrosAKm(
        _locationService.calcularDistanciaTotal(_puntos),
      );
      notifyListeners();
    });
  }

  void _iniciarTimerStorage() {
    _timerStorage = Timer.periodic(const Duration(seconds: 30), (_) {
      _guardarEnStorage();
    });
  }

  void _iniciarCronometro() {
    _timerCronometro = Timer.periodic(const Duration(seconds: 1), (_) {
      _segundos++;
      notifyListeners();
    });
  }

  void _detenerTimers() {
    _timerGPS?.cancel();
    _timerStorage?.cancel();
    _timerCronometro?.cancel();
    _timerGPS = null;
    _timerStorage = null;
    _timerCronometro = null;
  }

  // ── Persistencia SharedPreferences ───────────────────────────────────────────

  Future<void> _guardarEnStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final puntosJson =
        _puntos.map((p) => '${p.latitude},${p.longitude}').toList();

    await prefs.setBool('tracking_activo', true);
    await prefs.setStringList('tracking_puntos', puntosJson);
    await prefs.setDouble('tracking_km', _kmRecorridos);
    await prefs.setString('tracking_nombre_inicio', _nombreInicio);
    await prefs.setInt('tracking_segundos', _segundos);
  }

  Future<void> _limpiarStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tracking_activo');
    await prefs.remove('tracking_puntos');
    await prefs.remove('tracking_km');
    await prefs.remove('tracking_nombre_inicio');
    await prefs.remove('tracking_segundos');
  }

  Future<void> _verificarRecorridoPendiente() async {
    // Solo verifica — no hace nada automáticamente
    // La UI decide qué hacer con el recorrido pendiente
    final pendiente = await hayRecorridoPendiente();
    if (pendiente) notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────

  void _resetear() {
    _estado = EstadoTracking.inactivo;
    _puntos = [];
    _kmRecorridos = 0;
    _segundos = 0;
    _puntoInicio = null;
    _puntoFin = null;
    _nombreInicio = '';
    _nombreFin = '';
  }

  @override
  void dispose() {
    _detenerTimers();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
