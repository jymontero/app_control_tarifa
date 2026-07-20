import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/reportes_provider.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';

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

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportesProvider>().cargarDatos());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  double _pctVsMeta(int monto, int meta) {
    if (meta <= 0) return 0;
    return (monto / meta * 100).clamp(0, 999);
  }

  Color _colorBadge(double pct) {
    if (pct >= 100) return _C.green;
    if (pct >= 60) return _C.accent;
    return _C.red;
  }

  String _labelBadge(double pct) {
    if (pct >= 100) return '+${(pct - 100).toStringAsFixed(0)}%';
    return '-${(100 - pct).toStringAsFixed(0)}%';
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
            _buildSelectorPeriodo(),
            _buildNavegacion(),
            Expanded(
              child: Consumer<ReportesProvider>(
                builder: (_, prov, __) {
                  if (prov.cargando) {
                    return const Center(
                        child: CircularProgressIndicator(color: _C.accent));
                  }
                  if (prov.error.isNotEmpty) {
                    return _buildError(prov);
                  }
                  if (!prov.hayDatos) {
                    return _buildEstadoVacio(prov);
                  }
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildHeroResumen(prov),
                      _buildMetricas(prov),
                      _buildGrafica(prov),
                      _buildComparativas(prov),
                      _buildListaHeader(prov),
                      _buildListaDias(prov),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Selector período ──────────────────────────────────────────────────────────

  Widget _buildSelectorPeriodo() {
    return Consumer<ReportesProvider>(
      builder: (_, prov, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _periodoBtn('Semanal', 'semanal', prov),
              _periodoBtn('Mensual', 'mensual', prov),
              _periodoBtn('Anual', 'anual', prov),
            ],
          ),
        );
      },
    );
  }

  Widget _periodoBtn(String label, String value, ReportesProvider prov) {
    final isActive = prov.periodo == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => prov.setPeriodo(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _C.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF0F1923) : _C.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Navegación ────────────────────────────────────────────────────────────────

  Widget _buildNavegacion() {
    return Consumer<ReportesProvider>(
      builder: (_, prov, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: prov.navegarAnterior,
                child: const Icon(Icons.chevron_left,
                    color: _C.secondary, size: 22),
              ),
              Text(
                prov.labelNavegacion,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              GestureDetector(
                onTap: prov.puedeNavegaSiguiente ? prov.navegarSiguiente : null,
                child: Icon(
                  Icons.chevron_right,
                  color: prov.puedeNavegaSiguiente ? _C.secondary : _C.muted,
                  size: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Hero resumen ──────────────────────────────────────────────────────────────

  Widget _buildHeroResumen(ReportesProvider prov) {
    final r = prov.resumen;
    final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    //final metaPeriodo = meta * r.diasLaborados;
    final metaPeriodo = r.salarioObjetivo;
    final pct = _pctVsMeta(r.totalGanancia, metaPeriodo);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GANANCIA NETA',
                    style: TextStyle(
                      fontSize: 10,
                      color: _C.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _fmt.format(r.totalGanancia),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _C.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _colorBadge(pct).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _colorBadge(pct).withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      'vs meta',
                      style: TextStyle(fontSize: 9, color: _colorBadge(pct)),
                    ),
                    Text(
                      _labelBadge(pct),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _colorBadge(pct),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Desglose bruto / deducciones
          Row(
            children: [
              _desglosItem('Total bruto', r.totalGanancia, _C.primary),
              _desglosItem('Deducciones', r.totalDeducciones, _C.red),
              _desglosItem('Días trab.', r.diasLaborados, _C.accent,
                  esMonto: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _desglosItem(String label, int valor, Color color,
      {bool esMonto = true}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(7),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 8, color: _C.secondary)),
            const SizedBox(height: 2),
            Text(
              esMonto ? '\$${_compacto(valor)}' : '$valor',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Métricas ──────────────────────────────────────────────────────────────────

  Widget _buildMetricas(ReportesProvider prov) {
    final r = prov.resumen;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Row(
        children: [
          _metricItem('Servicios', '${r.totalServicios}', _C.primary, true),
          _metricItem('Promedio/día',
              '\$${_compacto(r.promedioPorDia.toInt())}', _C.primary, true),
          _metricItem(
              'Mejor día', '\$${_compacto(r.mejorDia)}', _C.green, true),
          _metricItem('Peor día', '\$${_compacto(r.peorDia)}', _C.red, false),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color, bool hasBorder) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: hasBorder
            ? const BoxDecoration(
                border: Border(right: BorderSide(color: _C.cardBorder)))
            : null,
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 8, color: _C.secondary)),
          ],
        ),
      ),
    );
  }

  // ── Gráfica ───────────────────────────────────────────────────────────────────

  Widget _buildGrafica(ReportesProvider prov) {
    final datos = prov.datosGrafica;
    if (datos.isEmpty) return const SizedBox();

    final maxVal = datos.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TENDENCIA',
              style: TextStyle(fontSize: 9, color: _C.secondary)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: datos.map((entry) {
              final pct = _pctVsMeta(entry.value, meta);
              final color = _colorBadge(pct);
              final altura = maxVal > 0
                  ? (entry.value / maxVal * 50).clamp(4.0, 50.0)
                  : 4.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: altura,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(entry.key,
                          style: const TextStyle(fontSize: 7, color: _C.muted)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _leyenda(_C.green, 'Sobre meta'),
              const SizedBox(width: 10),
              _leyenda(_C.accent, 'Parcial'),
              const SizedBox(width: 10),
              _leyenda(_C.red, 'Bajo meta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leyenda(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 8, color: _C.secondary)),
      ],
    );
  }

  // ── Comparativas ─────────────────────────────────────────────────────────────

  Widget _buildComparativas(ReportesProvider prov) {
    final r = prov.resumen;
    if (r.totalServicios == 0) return const SizedBox();

    // Nota: registros viejos sin tipo/pago cuentan como taxi/efectivo
    final pctTaxi = r.totalServicios > 0 ? 100.0 : 0.0;
    final pctEfectivo = r.totalServicios > 0 ? 100.0 : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMPARATIVAS',
              style: TextStyle(fontSize: 9, color: _C.secondary)),
          const SizedBox(height: 10),

          // Taxi vs Plataforma
          _comparativaBar(
            label: 'Taxi vs Plataforma',
            labelA: 'Taxi',
            labelB: 'Plataforma',
            pctA: pctTaxi,
            colorA: _C.accent,
            colorB: _C.blue,
            totalA: r.totalServicios,
            totalB: 0,
          ),
          const SizedBox(height: 10),

          // Efectivo vs Transferencia
          _comparativaBar(
            label: 'Efectivo vs Transferencia',
            labelA: 'Efectivo',
            labelB: 'Transf.',
            pctA: pctEfectivo,
            colorA: _C.green,
            colorB: _C.purple,
            totalA: r.totalServicios,
            totalB: 0,
          ),
        ],
      ),
    );
  }

  Widget _comparativaBar({
    required String label,
    required String labelA,
    required String labelB,
    required double pctA,
    required Color colorA,
    required Color colorB,
    required int totalA,
    required int totalB,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: pctA.toInt(),
                child: Container(height: 8, color: colorA.withOpacity(0.7)),
              ),
              if (100 - pctA.toInt() > 0)
                Expanded(
                  flex: (100 - pctA.toInt()),
                  child: Container(height: 8, color: colorB.withOpacity(0.7)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _leyendaDetalle(colorA, labelA, totalA),
            _leyendaDetalle(colorB, labelB, totalB),
          ],
        ),
      ],
    );
  }

  Widget _leyendaDetalle(Color color, String label, int total) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text('$label · $total',
            style: const TextStyle(fontSize: 9, color: _C.secondary)),
      ],
    );
  }

  // ── Lista header ──────────────────────────────────────────────────────────────

  Widget _buildListaHeader(ReportesProvider prov) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Detalle por día',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
          Text(
            '${prov.resumen.diasLaborados} registros',
            style: const TextStyle(fontSize: 10, color: _C.accent),
          ),
        ],
      ),
    );
  }

  // ── Lista días ────────────────────────────────────────────────────────────────

  Widget _buildListaDias(ReportesProvider prov) {
    final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    final dias = prov.diasDetalle;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 5),
      itemBuilder: (_, i) => _buildDiaItem(dias[i], meta),
    );
  }

  Widget _buildDiaItem(ResumenDia dia, int meta) {
    final pct = _pctVsMeta(dia.ganancia, meta);
    final color = _colorBadge(pct);
    final fecha = DateFormat.yMMMEd('es').format(dia.fecha);

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Fila superior
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fecha,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _C.primary,
                        )),
                    if (dia.numServicios > 0)
                      Text(
                        '${dia.numServicios} servicios',
                        style:
                            const TextStyle(fontSize: 9, color: _C.secondary),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _labelBadge(pct),
                  style: TextStyle(fontSize: 9, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Desglose
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _desgloseDia(
                  'Total bruto',
                  dia.totalBruto > 0 ? _fmt.format(dia.totalBruto) : '--',
                  _C.primary,
                ),
                _desgloseDia(
                  'Deducciones',
                  dia.deducciones > 0
                      ? '-${_fmt.format(dia.deducciones)}'
                      : '--',
                  _C.red,
                ),
                _desgloseDia(
                  'Ganancia',
                  _fmt.format(dia.ganancia),
                  _C.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _desgloseDia(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: _C.secondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio(ReportesProvider prov) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_outlined, color: _C.muted, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sin datos para ${prov.labelNavegacion}',
            style: const TextStyle(color: _C.secondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Finaliza turnos para ver tus reportes',
            style: TextStyle(color: _C.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────────

  Widget _buildError(ReportesProvider prov) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _C.red, size: 40),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: prov.cargarDatos,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _C.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.accent.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: _C.accent, size: 16),
                  SizedBox(width: 6),
                  Text('Reintentar',
                      style: TextStyle(color: _C.accent, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
