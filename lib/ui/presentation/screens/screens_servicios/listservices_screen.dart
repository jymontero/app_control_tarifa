import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const heroBg = Color(0xFF1A3A5C);
  static const heroBorder = Color(0xFF1E3A55);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
  static const blue = Color(0xFF60A5FA);
  static const purple = Color(0xFFA78BFA);
}

class DetalleServiciosDiaScreen extends StatefulWidget {
  final String fecha; // formato: 'dia-mes-anio' para consulta Firebase
  final String fechaFormateada; // formato legible para el header

  const DetalleServiciosDiaScreen({
    super.key,
    required this.fecha,
    required this.fechaFormateada,
  });

  @override
  State<DetalleServiciosDiaScreen> createState() =>
      _DetalleServiciosDiaScreenState();
}

class _DetalleServiciosDiaScreenState extends State<DetalleServiciosDiaScreen> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  List<Servicio> _listaServicios = [];
  bool _cargando = true;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarServicios() async {
    final lista = await _bd.getModeloServicios(widget.fecha);
    lista.sort((a, b) {
      try {
        return DateFormat.jm()
            .parse(a.hora)
            .compareTo(DateFormat.jm().parse(b.hora));
      } catch (_) {
        return a.hora.compareTo(b.hora);
      }
    });
    if (!mounted) return;
    setState(() {
      _listaServicios = lista.reversed.toList(); // más reciente primero
      _cargando = false;
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  // Cálculos del resumen
  int get _totalDia => _listaServicios.fold(0, (s, i) => s + i.valorservicio);
  int get _promedio =>
      _listaServicios.isNotEmpty ? _totalDia ~/ _listaServicios.length : 0;
  int get _taxiCount =>
      _listaServicios.where((s) => s.tipoServicio == 'taxi').length;
  int get _plataformaCount =>
      _listaServicios.where((s) => s.tipoServicio == 'plataforma').length;
  int get _efectivoTotal => _listaServicios
      .where((s) => s.metodoPago == 'efectivo')
      .fold(0, (s, i) => s + i.valorservicio);
  int get _transferenciaTotal => _listaServicios
      .where((s) => s.metodoPago == 'transferencia')
      .fold(0, (s, i) => s + i.valorservicio);

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : _listaServicios.isEmpty
                      ? _buildEstadoVacio()
                      : Column(
                          children: [
                            _buildResumen(),
                            _buildListaHeader(),
                            Expanded(child: _buildLista()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0D1F2D),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _C.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _C.secondary,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fechaFormateada,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              const Text(
                'Detalle de servicios',
                style: TextStyle(fontSize: 10, color: _C.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Resumen del día ───────────────────────────────────────────────────────────

  Widget _buildResumen() {
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
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total + servicios/promedio
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL DEL DÍA',
                        style: TextStyle(
                            fontSize: 9,
                            color: _C.secondary,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 3),
                    Text(
                      _fmt.format(_totalDia),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _infoChip('${_listaServicios.length} servicios', _C.accent),
                  const SizedBox(height: 4),
                  _infoChip('Prom. \$${_compacto(_promedio)}', _C.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Consolidado tipo + pago
          Row(
            children: [
              _consolidadoCard(
                titulo: 'Tipo servicio',
                filas: [
                  _FilaConsolidado('Taxi', '$_taxiCount', _C.accent),
                  _FilaConsolidado('Plataforma', '$_plataformaCount', _C.blue),
                ],
              ),
              const SizedBox(width: 6),
              _consolidadoCard(
                titulo: 'Método pago',
                filas: [
                  _FilaConsolidado(
                      'Efectivo', '\$${_compacto(_efectivoTotal)}', _C.green),
                  _FilaConsolidado('Transf.',
                      '\$${_compacto(_transferenciaTotal)}', _C.purple),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(texto,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _consolidadoCard({
    required String titulo,
    required List<_FilaConsolidado> filas,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(fontSize: 8, color: _C.secondary)),
            const SizedBox(height: 5),
            ...filas.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: f.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(f.label,
                              style: const TextStyle(
                                  fontSize: 9, color: _C.primary)),
                        ],
                      ),
                      Text(f.valor,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: f.color,
                          )),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Header lista ──────────────────────────────────────────────────────────────

  Widget _buildListaHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Servicios del turno',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
          Text(
            '${_listaServicios.length} registros',
            style: const TextStyle(fontSize: 10, color: _C.accent),
          ),
        ],
      ),
    );
  }

  // ── Lista ─────────────────────────────────────────────────────────────────────

  Widget _buildLista() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: _listaServicios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) => _buildServicioItem(_listaServicios[i], i + 1),
    );
  }

  Widget _buildServicioItem(Servicio s, int numero) {
    final esTaxi = s.tipoServicio == 'taxi';
    final esEfectivo = s.metodoPago == 'efectivo';
    final colorTipo = esTaxi ? _C.accent : _C.blue;
    final colorPago = esEfectivo ? _C.green : _C.purple;

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          // Ícono tipo servicio
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorTipo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              esTaxi ? Icons.local_taxi_rounded : Icons.phone_android_outlined,
              color: colorTipo,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servicio #${_listaServicios.length - numero + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.hora,
                  style: const TextStyle(fontSize: 9, color: _C.secondary),
                ),
              ],
            ),
          ),

          // Badges + valor
          Row(
            children: [
              _badge(esTaxi ? 'Taxi' : 'Plataforma', colorTipo),
              const SizedBox(width: 4),
              _badge(esEfectivo ? 'Efectivo' : 'Transf.', colorPago),
              const SizedBox(width: 8),
              Text(
                '+${_fmt.format(s.valorservicio)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _C.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(texto, style: TextStyle(fontSize: 8, color: color)),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_taxi_outlined, color: _C.muted, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sin servicios para ${widget.fechaFormateada}',
            style: const TextStyle(color: _C.secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Modelo auxiliar ───────────────────────────────────────────────────────────

class _FilaConsolidado {
  final String label;
  final String valor;
  final Color color;
  const _FilaConsolidado(this.label, this.valor, this.color);
}
