import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Convierte coordenadas a nombre de barrio/lugar
  /// Usa Nominatim (OpenStreetMap) — completamente gratuito
  Future<String> obtenerNombreLugar(LatLng punto) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=${punto.latitude}&lon=${punto.longitude}'
        '&format=json&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {
          // Nominatim requiere User-Agent identificando la app
          'User-Agent': 'TaxiApp/1.0',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return 'Ubicación desconocida';

      final data = json.decode(response.body);
      final address = data['address'] as Map<String, dynamic>?;

      if (address == null) return 'Ubicación desconocida';

      // Prioridad: barrio > suburbio > distrito > ciudad
      return address['neighbourhood'] as String? ??
          address['suburb'] as String? ??
          address['district'] as String? ??
          address['city_district'] as String? ??
          address['town'] as String? ??
          address['city'] as String? ??
          'Ubicación desconocida';
    } catch (e) {
      return 'Ubicación desconocida';
    }
  }
}
