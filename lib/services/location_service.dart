import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // ── Permisos ─────────────────────────────────────────────────────────────────

  /// Verifica y solicita permisos de ubicación
  /// Retorna true si tiene permisos, false si no
  Future<bool> verificarPermisos() async {
    // Verificar si el servicio de ubicación está activo
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) return false;

    LocationPermission permiso = await Geolocator.checkPermission();

    // Si está denegado permanentemente no podemos pedir
    if (permiso == LocationPermission.deniedForever) return false;

    // Si está denegado — pedirlo
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return false;
    }

    return true;
  }

  /// Verifica si el GPS está activo
  Future<bool> gpsActivo() async => await Geolocator.isLocationServiceEnabled();

  /// Abre configuración del GPS del dispositivo
  Future<void> abrirConfiguracionGPS() async =>
      await Geolocator.openLocationSettings();

  // ── Posición actual ───────────────────────────────────────────────────────────

  /// Obtiene la posición actual del dispositivo
  Future<LatLng?> obtenerPosicionActual() async {
    try {
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(posicion.latitude, posicion.longitude);
    } catch (e) {
      return null;
    }
  }

  /// Stream de posiciones — emite cada vez que el dispositivo se mueve
  Stream<LatLng> streamPosicion() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // solo emite si se movió más de 5 metros
      ),
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  // ── Cálculos de distancia (Haversine) ────────────────────────────────────────

  /// Calcula distancia en metros entre dos puntos usando Haversine
  /// La Tierra no es plana — necesitamos trigonometría esférica
  double calcularDistanciaMetros(LatLng p1, LatLng p2) {
    const R = 6371000.0; // radio de la Tierra en metros

    // Convertir grados a radianes
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLng = (p2.longitude - p1.longitude) * pi / 180;

    // Fórmula Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // distancia en metros
  }

  /// Calcula la distancia total de una lista de puntos
  double calcularDistanciaTotal(List<LatLng> puntos) {
    if (puntos.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < puntos.length - 1; i++) {
      total += calcularDistanciaMetros(puntos[i], puntos[i + 1]);
    }
    return total;
  }

  /// Convierte metros a kilómetros con 2 decimales
  double metrosAKm(double metros) =>
      double.parse((metros / 1000).toStringAsFixed(2));
}
