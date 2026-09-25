import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
}

class VerRutaScreen extends StatelessWidget {
  final Servicio servicio;

  VerRutaScreen({super.key, required this.servicio});

  // Convertir GeoPoints a LatLng para flutter_map
  List<LatLng> get _puntos =>
      servicio.rutaPuntos.map((p) => LatLng(p.latitude, p.longitude)).toList();

  LatLng? get _inicio => servicio.puntoInicio != null
      ? LatLng(servicio.puntoInicio!.latitude, servicio.puntoInicio!.longitude)
      : null;

  LatLng? get _fin => servicio.puntoFin != null
      ? LatLng(servicio.puntoFin!.latitude, servicio.puntoFin!.longitude)
      : null;

  // Centro del mapa — punto medio de la ruta
  LatLng get _centro {
    if (_puntos.isEmpty) return const LatLng(4.7110, -74.0721);
    final latMin =
        _puntos.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final latMax =
        _puntos.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final lngMin =
        _puntos.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final lngMax =
        _puntos.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    return LatLng((latMin + latMax) / 2, (lngMin + lngMax) / 2);
  }

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: _centro,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.taxi.servicios',
              ),
              // Ruta completa
              if (_puntos.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _puntos,
                      color: _C.accent,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              // Marcadores inicio y fin
              MarkerLayer(
                markers: [
                  if (_inicio != null)
                    Marker(
                      point: _inicio!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _C.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  if (_fin != null)
                    Marker(
                      point: _fin!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _C.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.stop_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Header ────────────────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _C.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.cardBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _C.secondary, size: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _C.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.cardBorder),
                    ),
                    child: Text(
                      servicio.nombreInicio.isNotEmpty
                          ? '${servicio.nombreInicio} → ${servicio.nombreFin}'
                          : 'Ruta del servicio',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _C.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel inferior ────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D1F2D),
                border: Border(top: BorderSide(color: _C.cardBorder)),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              child: Row(
                children: [
                  _resumenItem(
                    '${servicio.kmRecorridos.toStringAsFixed(1)} km',
                    'Recorrido',
                    _C.accent,
                  ),
                  _resumenItem(
                    servicio.nombreInicio.isNotEmpty
                        ? servicio.nombreInicio
                        : '--',
                    'Inicio',
                    _C.green,
                  ),
                  _resumenItem(
                    servicio.nombreFin.isNotEmpty ? servicio.nombreFin : '--',
                    'Fin',
                    _C.red,
                  ),
                  _resumenItem(
                    NumberFormat.currency(
                      locale: 'es_MX',
                      symbol: '\$',
                      decimalDigits: 0,
                    ).format(servicio.valorservicio),
                    'Valor',
                    _C.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenItem(String valor, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 8, color: _C.secondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
