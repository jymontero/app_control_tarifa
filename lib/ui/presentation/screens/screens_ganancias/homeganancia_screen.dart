import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/providers/ingresos_provider.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/listservices_screen.dart';

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
  static const purple = Color(0xFFA78BFA);
}

class HomeGanancia extends StatefulWidget {
  const HomeGanancia({super.key});

  @override
  State<HomeGanancia> createState() => _HomeGananciaState();
}

class _HomeGananciaState extends State<HomeGanancia> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  DateTime _selectedDate = DateTime.now().toLocal();
  late Future<List<Ingreso>> _ingresosFuture;
  List<Ingreso> _listaIngresos = [];
  String _periodo = 'mensual'; // 'mensual' | 'anual'

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _cargarIngresos();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  void _cargarIngresos() {
    if (_periodo == 'mensual') {
      _ingresosFuture = _bd.getModeloIngresos(
        _selectedDate.month.toString(),
        _selectedDate.year.toString(),
      );
    } else {
      _ingresosFuture = _cargarIngresosAnual();
    }
  }

  Future<List<Ingreso>> _cargarIngresosAnual() async {
    final futures = List.generate(12, (i) {
      return _bd.getModeloIngresos(
        (i + 1).toString(),
        _selectedDate.year.toString(),
      );
    });
    final resultados = await Future.wait(futures);
    return resultados.expand((l) => l).toList();
  }

  List<Ingreso> _ordenarLista(List<Ingreso> lista) {
    lista.sort((a, b) => int.parse(b.dia).compareTo(int.parse(a.dia)));
    return lista;
  }

  int _sumarLista(List<Ingreso> lista) =>
      lista.fold(0, (sum, item) => sum + item.monto);

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    //if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(1)}k';
    return _fmt.format(valor);
    //valor.toString();
  }

  String _nombreMes() => DateFormat.MMMM('es').format(_selectedDate);

  DateTime _fechaIngreso(Ingreso i) =>
      DateFormat('d-M-yyyy').parse('${i.dia}-${i.mes}-${i.anio}');

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

  void _cambiarMes(int delta) {
    setState(() {
      if (_periodo == 'mensual') {
        _selectedDate =
            DateTime(_selectedDate.year, _selectedDate.month + delta);
      } else {
        _selectedDate = DateTime(_selectedDate.year + delta);
      }
      _cargarIngresos();
    });
  }

  void _cambiarPeriodo(String periodo) {
    if (_periodo == periodo) return;
    setState(() {
      _periodo = periodo;
      _selectedDate = DateTime.now();
      _cargarIngresos();
    });
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
            _buildSelectorMes(),
            Expanded(
              child: FutureBuilder<List<Ingreso>>(
                future: _ingresosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: _C.accent));
                  }
                  if (snapshot.hasError) {
                    return _buildError();
                  }
                  if (snapshot.hasData) {
                    _listaIngresos = _ordenarLista(snapshot.data!);
                    final saldo = _sumarLista(_listaIngresos);
                    final diasLaborados = _listaIngresos.length;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context
                            .read<IngresosProvider>()
                            .setIngresoMensual(saldo);
                        context
                            .read<IngresosProvider>()
                            .setDiasLaborados(diasLaborados);
                      }
                    });

                    return Column(
                      children: [
                        _buildResumenMes(saldo, diasLaborados),
                        _buildMetricasRow(saldo, diasLaborados),
                        _buildGraficaTendencia(),
                        _buildListaHeader(),
                        Expanded(
                            child: _listaIngresos.isEmpty
                                ? _buildEstadoVacio()
                                : (_periodo == 'mensual'
                                    ? _buildListaIngresos()
                                    : _buildListaIngresosAnual())),
                      ],
                    );
                  }
                  return const SizedBox();
                },
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
              GestureDetector(
                onTap: () => _cambiarMes(-1),
                child: const Icon(Icons.chevron_left,
                    color: _C.secondary, size: 22),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () async {
                  final DateTime? selected = await showMonthPicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                    locale: const Locale('es'),
                  );
                  if (selected != null && selected != _selectedDate) {
                    setState(() {
                      _selectedDate = selected;
                      _cargarIngresos();
                    });
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: _C.accent, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      _periodo == 'mensual'
                          ? '${_nombreMes().substring(0, 1).toUpperCase()}${_nombreMes().substring(1)} ${_selectedDate.year}'
                          : '${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _cambiarMes(1),
                child: const Icon(Icons.chevron_right,
                    color: _C.secondary, size: 22),
              ),
            ],
          ),
          Consumer<IngresosProvider>(
            builder: (_, prov, __) => Text(
              '${prov.diasLaborados} días laborados',
              style: const TextStyle(fontSize: 10, color: _C.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorPeriodo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.cardBorder),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _periodoBtn('Mensual', 'mensual'),
            _periodoBtn('Anual', 'anual'),
          ],
        ),
      ),
    );
  }

  Widget _periodoBtn(String label, String value) {
    final isActive = _periodo == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _cambiarPeriodo(value),
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
  // ── Resumen hero ──────────────────────────────────────────────────────────────

  Widget _buildResumenMes(int saldo, int diasLaborados) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _periodo == 'mensual'
                ? 'SALDO ${_nombreMes().toUpperCase()} ${_selectedDate.year}'
                : 'SALDO AÑO ${_selectedDate.year}',
            style: const TextStyle(
                fontSize: 10, color: _C.secondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt.format(saldo),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Métricas ──────────────────────────────────────────────────────────────────

  Widget _buildMetricasRow(int saldo, int diasLaborados) {
    final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    final promedio = diasLaborados > 0 ? saldo ~/ diasLaborados : 0;
    final mejor = _listaIngresos.isEmpty
        ? 0
        : _listaIngresos.map((e) => e.monto).reduce((a, b) => a > b ? a : b);
    final deduccionesC = _listaIngresos.isEmpty
        ? 0
        : _listaIngresos.fold(0, (sum, item) => sum + item.sueldoObjetivo);
    //final pctMeta = _pctVsMeta(saldo, deduccionesC * diasLaborados);
    final pctMeta = _pctVsMeta(saldo, deduccionesC);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Row(
        children: [
          _metricItem(
            label: 'Promedio/día',
            value: _compacto(promedio),
            color: _C.primary,
            hasBorder: true,
          ),
          _metricItem(
            label: 'Mejor día',
            value: _compacto(mejor),
            color: _C.green,
            hasBorder: true,
          ),
          _metricItem(
            label: 'Vs meta',
            value: _labelBadge(pctMeta),
            color: pctMeta >= 100 ? _C.green : _C.red,
            hasBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _metricItem({
    required String label,
    required String value,
    required Color color,
    required bool hasBorder,
  }) {
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: _C.secondary)),
          ],
        ),
      ),
    );
  }

  // ── Gráfica tendencia ─────────────────────────────────────────────────────────

  Widget _buildGraficaTendencia() {
    if (_listaIngresos.isEmpty) return const SizedBox();

    List<_BarraGrafica> barras;
    int maxMonto;

    if (_periodo == 'mensual') {
      final lista = [..._listaIngresos]
        ..sort((a, b) => int.parse(a.dia).compareTo(int.parse(b.dia)));

      barras = lista
          .map((i) => _BarraGrafica(
                label: i.dia,
                monto: i.monto,
                meta: i.sueldoObjetivo, // ← meta real del día
              ))
          .toList();

      maxMonto = barras.map((b) => b.monto).reduce((a, b) => a > b ? a : b);
    } else {
      final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
      final Map<int, int> porMes = {};
      final Map<int, int> diasPorMes = {};
      final Map<int, int> metaPorMes = {};

      for (final i in _listaIngresos) {
        final mes = int.parse(i.mes);
        porMes[mes] = (porMes[mes] ?? 0) + i.monto;
        diasPorMes[mes] = (diasPorMes[mes] ?? 0) + 1;
        metaPorMes[mes] = (metaPorMes[mes] ?? 0) + i.sueldoObjetivo;
      }

      const mesesCortos = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic'
      ];

      barras = List.generate(12, (i) {
        final mes = i + 1;
        return _BarraGrafica(
          label: mesesCortos[i],
          monto: porMes[mes] ?? 0,
          meta: metaPorMes[mes] ?? 0,
        );
      }).where((b) => b.monto > 0).toList();

      if (barras.isEmpty) return const SizedBox();

      maxMonto = barras.map((b) => b.monto).reduce((a, b) => a > b ? a : b);
    }

    return _buildGraficaWidget(
      titulo: _periodo == 'mensual' ? 'TENDENCIA DEL MES' : 'TENDENCIA DEL AÑO',
      barras: barras,
      maxMonto: maxMonto,
    );
  }

  Widget _buildGraficaWidget({
    required String titulo,
    required List<_BarraGrafica> barras,
    required int maxMonto,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(fontSize: 9, color: _C.secondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: barras.map((b) {
              final pct = _pctVsMeta(b.monto, b.meta);
              final color = _colorBadge(pct);
              final altura = maxMonto > 0
                  ? (b.monto / maxMonto * 40).clamp(4.0, 40.0)
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
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(b.label,
                          style: const TextStyle(
                              fontSize: 7, color: _C.secondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _leyendaItem(_C.green, 'Sobre meta'),
              const SizedBox(width: 10),
              _leyendaItem(_C.accent, 'Parcial'),
              const SizedBox(width: 10),
              _leyendaItem(_C.red, 'Bajo meta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leyendaItem(Color color, String label) {
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

  // ── Header lista ──────────────────────────────────────────────────────────────

  Widget _buildListaHeader() {
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
            '${_listaIngresos.length} registros',
            style: const TextStyle(fontSize: 10, color: _C.accent),
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, color: _C.muted, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sin datos de ${_nombreMes()}',
            style: const TextStyle(color: _C.secondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Finaliza un turno para ver tus ingresos',
            style: TextStyle(color: _C.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Lista ingresos ────────────────────────────────────────────────────────────

  Widget _buildListaIngresos() {
    final meta = context.read<ConfiguracionProvider>().metaRegistradaBD;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _listaIngresos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) =>
          _buildIngresoItem(_listaIngresos[index], meta),
    );
  }

  Widget _buildIngresoItem(Ingreso ingreso, int meta) {
    final pct = _pctVsMeta(ingreso.monto, ingreso.sueldoObjetivo);
    final color = _colorBadge(pct);
    final fecha = _fechaIngreso(ingreso);

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: fecha + badge + servicios
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMEd('es').format(fecha),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.primary,
                      ),
                    ),
                    if (ingreso.numServicios > 0)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalleServiciosDiaScreen(
                              fecha:
                                  '${ingreso.dia}-${ingreso.mes}-${ingreso.anio}',
                              fechaFormateada: DateFormat.yMMMEd('es').format(
                                DateFormat('d-M-yyyy').parse(
                                    '${ingreso.dia}-${ingreso.mes}-${ingreso.anio}'),
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${ingreso.numServicios} servicios',
                              style: const TextStyle(
                                fontSize: 9,
                                color: _C.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 8, color: _C.accent),
                          ],
                        ),
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
                  '${_labelBadge(pct)} meta',
                  style: TextStyle(fontSize: 9, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Desglose: bruto / deducciones / ganancia
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _desglosItem(
                  label: 'Total bruto',
                  value: ingreso.totalBruto > 0
                      ? _fmt.format(ingreso.totalBruto)
                      : '--',
                  color: _C.primary,
                ),
                _desglosItem(
                  label: 'Deducciones',
                  value: ingreso.deducciones > 0
                      ? '-${_fmt.format(ingreso.deducciones)}'
                      : '--',
                  color: _C.red,
                ),
                _desglosItem(
                  label: 'Ganancia',
                  value: _fmt.format(ingreso.monto),
                  color: _C.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _pagoChip('Efectivo', ingreso.totalEfectivo, _C.green),
              const SizedBox(width: 6),
              _pagoChip('Transf.', ingreso.totalTransferencia, _C.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaIngresosAnual() {
    final Map<int, List<Ingreso>> porMes = {};
    for (final i in _listaIngresos) {
      final mes = int.parse(i.mes);
      porMes[mes] = [...(porMes[mes] ?? []), i];
    }

    final mesesOrdenados = porMes.keys.toList()..sort((a, b) => b.compareTo(a));

    const meses = [
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: mesesOrdenados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final mes = mesesOrdenados[i];
        final lista = porMes[mes]!;
        final totalGanancia = lista.fold(0, (s, x) => s + x.monto);
        final totalBruto = lista.fold(0, (s, x) => s + x.totalBruto);
        final totalDeducciones = lista.fold(0, (s, x) => s + x.deducciones);
        final totalServicios = lista.fold(0, (s, x) => s + x.numServicios);
        final totalEfectivo = lista.fold(0, (s, x) => s + x.totalEfectivo);
        final totalTransferencia =
            lista.fold(0, (s, x) => s + x.totalTransferencia);
        final metaMes = lista.fold(0, (s, x) => s + x.sueldoObjetivo);
        final pct = _pctVsMeta(totalGanancia, metaMes);
        final color = _colorBadge(pct);

        return Container(
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${meses[mes - 1]} ${_selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.primary,
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${lista.length} días laborados',
                                style: const TextStyle(
                                    fontSize: 9, color: _C.secondary)),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () {
                                // Cambia a vista mensual del mes tocado
                                setState(() {
                                  _periodo = 'mensual';
                                  _selectedDate =
                                      DateTime(_selectedDate.year, mes);
                                  _cargarIngresos();
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '$totalServicios servicios',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: _C.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 8, color: _C.accent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_labelBadge(pct),
                        style: TextStyle(fontSize: 9, color: color)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _desglosItem(
                        label: 'Bruto',
                        value: _compacto(totalBruto),
                        color: _C.primary),
                    _desglosItem(
                        label: 'Deducciones',
                        value: '-${_compacto(totalDeducciones)}',
                        color: _C.red),
                    _desglosItem(
                        label: 'Ganancia',
                        value: _compacto(totalGanancia),
                        color: _C.green),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _pagoChip('Efectivo', totalEfectivo, _C.green),
                  const SizedBox(width: 6),
                  _pagoChip('Transf.', totalTransferencia, _C.purple),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pagoChip(String label, int valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(fontSize: 9, color: _C.secondary)),
              ],
            ),
            Text(_compacto(valor),
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _desglosItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: _C.secondary)),
          const SizedBox(height: 3),
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

  // ── Error ─────────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _C.red, size: 40),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _cargarIngresos()),
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

// Fuera de la clase, al final del archivo
class _BarraGrafica {
  final String label;
  final int monto;
  final int meta;
  const _BarraGrafica({
    required this.label,
    required this.monto,
    required this.meta,
  });
}
