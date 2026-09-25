import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/tracking_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registroservicio_screen.dart';

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

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  bool _centrarMapa = true;

  @override
  void initState() {
    super.initState();
    _iniciarTracking();
  }

  Future<void> _iniciarTracking() async {
    final tracking = context.read<TrackingProvider>();

    // Verificar si hay recorrido pendiente
    final pendiente = await tracking.hayRecorridoPendiente();
    if (pendiente && mounted) {
      _mostrarDialogoRecuperacion();
      return;
    }

    // Iniciar tracking nuevo
    final iniciado = await tracking.iniciarTracking();
    if (!iniciado && mounted) {
      _mostrarDialogoGPSError();
    }
  }

  // ── Diálogo GPS no disponible ─────────────────────────────────────────────────

  void _mostrarDialogoGPSError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text('GPS no disponible',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _C.primary, fontSize: 15, fontWeight: FontWeight.w500)),
        content: const Text(
          'No pudimos obtener tu ubicación.\nActiva el GPS para registrar el recorrido.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _C.secondary, fontSize: 12),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context
                  .read<TrackingProvider>()
                  .iniciarTracking(); // reintenta
            },
            child:
                const Text('Activar GPS', style: TextStyle(color: _C.accent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _irAFormulario(null);
            },
            child: const Text('Sin tracking',
                style: TextStyle(color: _C.secondary)),
          ),
        ],
      ),
    );
  }

  // ── Diálogo recuperación ──────────────────────────────────────────────────────

  void _mostrarDialogoRecuperacion() async {
    final tracking = context.read<TrackingProvider>();
    final datos = await tracking.obtenerRecorridoPendiente();
    if (!mounted || datos == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text('Recorrido sin finalizar',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _C.primary, fontSize: 15, fontWeight: FontWeight.w500)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Encontramos un recorrido activo que no fue finalizado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _C.secondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.cardBorder),
              ),
              child: Column(
                children: [
                  _infoFila('Km recorridos', '${datos['kmRecorridos']} km',
                      _C.accent),
                  _infoFila('Inicio', datos['nombreInicio'], _C.green),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await tracking.continuarRecorrido(datos);
            },
            child: const Text('Continuar', style: TextStyle(color: _C.accent)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await tracking.descartarRecorrido();
              _irAFormulario(null);
            },
            child: const Text('Descartar', style: TextStyle(color: _C.red)),
          ),
        ],
      ),
    );
  }

  Widget _infoFila(String label, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: _C.secondary)),
          Text(valor,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  // ── Finalizar ─────────────────────────────────────────────────────────────────

  Future<void> _finalizar() async {
    final tracking = context.read<TrackingProvider>();
    final datos = await tracking.finalizarTracking();
    if (mounted) _irAFormulario(datos);
  }

  void _irAFormulario(Map<String, dynamic>? datoTracking) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroServicio(datoTracking: datoTracking),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Consumer<TrackingProvider>(
        builder: (_, tracking, __) {
          // Centrar mapa en posición actual
          if (_centrarMapa && tracking.puntos.isNotEmpty && tracking.activo) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                _mapController.move(tracking.puntos.last, 16);
              } catch (_) {}
            });
          }

          return Stack(
            children: [
              // ── Mapa ────────────────────────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: tracking.puntos.isNotEmpty
                      ? tracking.puntos.last
                      : const LatLng(4.7110, -74.0721),
                  initialZoom: 16,
                  onMapEvent: (event) {
                    // Si el usuario mueve el mapa manualmente deja de centrar
                    if (event is MapEventMove &&
                        event.source == MapEventSource.dragStart) {
                      setState(() => _centrarMapa = false);
                    }
                  },
                ),
                children: [
                  // Tiles OpenStreetMap — gratuito
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.taxi.servicios',
                  ),
                  // Ruta dibujada
                  if (tracking.puntos.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: tracking.puntos,
                          color: _C.accent,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  // Marcadores inicio y posición actual
                  MarkerLayer(
                    markers: [
                      // Punto inicio
                      if (tracking.puntoInicio != null)
                        Marker(
                          point: tracking.puntoInicio!,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _C.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      // Posición actual
                      if (tracking.puntos.isNotEmpty)
                        Marker(
                          point: tracking.puntos.last,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _C.accent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // ── Badge grabando ───────────────────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: _C.red, size: 8),
                      SizedBox(width: 5),
                      Text('Grabando ruta',
                          style: TextStyle(
                              fontSize: 10,
                              color: _C.red,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

              // ── Label barrio actual ──────────────────────────────────────────
              if (tracking.nombreInicio.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 52,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _C.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _C.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      tracking.nombreInicio,
                      style: const TextStyle(
                          fontSize: 9,
                          color: _C.accent,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

              // ── Botón centrar ────────────────────────────────────────────────
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _centrarMapa = true);
                    if (tracking.puntos.isNotEmpty) {
                      _mapController.move(tracking.puntos.last, 16);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _C.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.cardBorder),
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        color: _C.accent, size: 16),
                  ),
                ),
              ),

              // ── Panel inferior fijo ──────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1F2D),
                    border: Border(top: BorderSide(color: _C.cardBorder)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    MediaQuery.of(context).padding.bottom + 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Métricas
                      Row(
                        children: [
                          _metricaItem(
                            '${tracking.kmRecorridos.toStringAsFixed(1)}',
                            'km',
                            _C.accent,
                          ),
                          _metricaItem(
                            tracking.tiempoFormateado,
                            'tiempo',
                            _C.primary,
                          ),
                          _metricaItem(
                            '${tracking.velocidadActual.toStringAsFixed(0)}',
                            'km/h',
                            _C.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Botón finalizar
                      GestureDetector(
                        onTap: _finalizar,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: _C.red,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Finalizar recorrido',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Loading inicial ──────────────────────────────────────────────
              if (tracking.cargando)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: _C.accent),
                        SizedBox(height: 12),
                        Text('Obteniendo ubicación...',
                            style: TextStyle(color: _C.primary, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricaItem(String valor, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.cardBorder),
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 8, color: _C.secondary)),
          ],
        ),
      ),
    );
  }
}
