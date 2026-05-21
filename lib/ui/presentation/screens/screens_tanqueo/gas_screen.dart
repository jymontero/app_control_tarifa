import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/domain/entitis/gas.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_EDS/listadoeds_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registroservicio_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const heroBg = Color(0xFF1A3A5C);
  static const heroBorder = Color(0xFF1E3A55);
  static const metricBg = Color(0xFF131F2B);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
}

class Gasoline extends StatefulWidget {
  const Gasoline({super.key});

  @override
  State<Gasoline> createState() => _GasolineState();
}

class _GasolineState extends State<Gasoline> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  List<GasolineTank> _listaTanqueo = [];
  List<EstacionGas> _listaEDS = [];
  bool _cargandoTanqueo = true;
  bool _cargandoEDS = true;
  DateTime _mesSeleccionado = DateTime.now();

  final _fmt = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarEDS(),
      _cargarTanqueo(),
    ]);
  }

  Future<void> _cargarEDS() async {
    final lista = await _bd.getMejorEDS();
    if (!mounted) return;
    setState(() {
      _listaEDS = lista;
      _cargandoEDS = false;
    });
  }

  Future<void> _cargarTanqueo() async {
    final lista = await _bd.getModeloTanqueo();
    if (!mounted) return;
    setState(() {
      _listaTanqueo = lista;
      _cargandoTanqueo = false;
    });
  }

  // ── Cálculos ─────────────────────────────────────────────────────────────────

  int get _totalGastado => _listaTanqueo.fold(0, (sum, t) => sum + t.valor);

  double get _totalGalones =>
      _listaTanqueo.fold(0.0, (sum, t) => sum + t.galon);

  int get _totalKm {
    return _listaTanqueo.fold(
      0,
      (sum, item) => sum + item.kilometraje,
    );
  }

  double get _rendimientoPromedio {
    if (_totalGalones <= 0) return 0;
    return _totalKm / _totalGalones;
  }

  double _rendimientoItem(GasolineTank t) {
    if (t.galon <= 0) return 0;
    return t.kilometraje / t.galon;
  }

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scroll
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  _buildSelectorMes(),
                  _buildCardEDS(),
                  _buildCardRendimiento(),
                  _buildHistorialHeader(),
                  _cargandoTanqueo
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(color: _C.accent),
                          ),
                        )
                      : _listaTanqueo.isEmpty
                          ? _buildEstadoVacio()
                          : _buildListaTanqueos(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Selector mes ──────────────────────────────────────────────────────────────

  Widget _buildSelectorMes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: _C.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _mesSeleccionado = DateTime(
                      _mesSeleccionado.year,
                      _mesSeleccionado.month - 1,
                    );
                  });
                },
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: _C.accent,
                    size: 12,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _mesActual(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: _C.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _mesSeleccionado = DateTime(
                      _mesSeleccionado.year,
                      _mesSeleccionado.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          Text(
            '${_listaTanqueo.length} tanqueos',
            style: const TextStyle(
              fontSize: 10,
              color: _C.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _mesActual() {
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    //final now = DateTime.now();
    //return '${meses[now.month - 1]} ${now.year}';
    return '${meses[_mesSeleccionado.month - 1]} ${_mesSeleccionado.year}';
  }

  // ── Card EDS activa ───────────────────────────────────────────────────────────

  Widget _buildCardEDS() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.heroBg, Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.heroBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: _cargandoEDS
          ? const Center(child: CircularProgressIndicator(color: _C.accent))
          : _listaEDS.isEmpty
              ? _buildSinEDS()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EDS info
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _C.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.local_gas_station_rounded,
                            color: _C.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _listaEDS.first.nombre,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _C.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _C.accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: _C.accent.withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      'Mejor Precio',
                                      style: TextStyle(
                                          fontSize: 9, color: _C.accent),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _listaEDS.first.barrio,
                                style: const TextStyle(
                                    fontSize: 10, color: _C.secondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Precio galón',
                              style:
                                  TextStyle(fontSize: 9, color: _C.secondary),
                            ),
                            Text(
                              _fmt.format(_listaEDS.first.valorgalon),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _C.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF1E3A55), height: 1),
                    const SizedBox(height: 12),
                    // Resumen mensual
                    Row(
                      children: [
                        _resumenItem(
                          label: 'Total gastado',
                          value: '\$${_compacto(_totalGastado)}',
                          color: _C.red,
                        ),
                        _resumenItem(
                          label: 'Total galones',
                          value: '${_totalGalones.toStringAsFixed(1)} gal',
                          color: _C.primary,
                        ),
                        _resumenItem(
                          label: 'Km recorridos',
                          value: '$_totalKm km',
                          color: _C.green,
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _resumenItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 8, color: _C.secondary)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSinEDS() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListEDS()),
        );
        _cargarEDS();
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: _C.accent, size: 16),
          SizedBox(width: 8),
          Text(
            'Agregar estación de servicio',
            style: TextStyle(
                fontSize: 12, color: _C.accent, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Card rendimiento ──────────────────────────────────────────────────────────

  Widget _buildCardRendimiento() {
    final rend = _rendimientoPromedio;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.speed_outlined, color: _C.green, size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rendimiento promedio',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _C.primary),
                ),
                Text(
                  'Km por galón este mes',
                  style: TextStyle(fontSize: 9, color: _C.secondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rend > 0 ? rend.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _C.green,
                ),
              ),
              const Text(
                'km/gal',
                style: TextStyle(fontSize: 9, color: _C.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Historial header ──────────────────────────────────────────────────────────

  Widget _buildHistorialHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Historial de tanqueos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListEDS()),
              );
              _cargarEDS();
            },
            child: const Text(
              '+ Gestionar EDS',
              style: TextStyle(
                  fontSize: 10, color: _C.accent, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.local_gas_station_outlined, color: _C.muted, size: 48),
            SizedBox(height: 12),
            Text(
              'Sin tanqueos registrados',
              style: TextStyle(color: _C.secondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lista tanqueos ────────────────────────────────────────────────────────────

  Widget _buildListaTanqueos() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _listaTanqueo.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildTanqueoItem(_listaTanqueo[index]);
      },
    );
  }

  Widget _buildTanqueoItem(GasolineTank t) {
    final rend = _rendimientoItem(t);
    final promedio = _rendimientoPromedio;

    // Badge de rendimiento
    Color badgeColor;
    String badgeLabel;
    if (rend >= promedio * 1.05) {
      badgeColor = _C.green;
      badgeLabel = 'Buen rend.';
    } else if (rend >= promedio * 0.95) {
      badgeColor = _C.accent;
      badgeLabel = 'Promedio';
    } else {
      badgeColor = _C.red;
      badgeLabel = 'Bajo rend.';
    }

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: _C.accent,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.fecha,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${t.kilometraje} km',
                      style: const TextStyle(fontSize: 9, color: _C.secondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${t.galon.toStringAsFixed(1)} gal',
                      style: const TextStyle(fontSize: 9, color: _C.secondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${rend.toStringAsFixed(1)} km/gal',
                      style: const TextStyle(fontSize: 9, color: _C.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt.format(t.valor),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(fontSize: 9, color: badgeColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
