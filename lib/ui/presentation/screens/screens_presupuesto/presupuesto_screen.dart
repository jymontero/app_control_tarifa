import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taxi_servicios/domain/entitis/presupuesto_mensual.dart';
import 'package:taxi_servicios/domain/entitis/presupuesto_item.dart';
import 'package:taxi_servicios/domain/entitis/movimiento_presupuesto.dart';
import 'package:taxi_servicios/domain/entitis/etiqueta.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/services/miles_input_formatter.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_calendarioTurno/turno_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_presupuesto/plantilla_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
  // ignore: unused_field
  static const purple = Color(0xFFA78BFA);
}

class PresupuestoScreen extends StatefulWidget {
  const PresupuestoScreen({super.key});

  @override
  State<PresupuestoScreen> createState() => _PresupuestoScreenState();
}

class _PresupuestoScreenState extends State<PresupuestoScreen> {
  final FireStoreDataBase _bd = FireStoreDataBase();
  DateTime _fechaNav = DateTime.now();
  PresupuestoMensual? _presupuesto;
  List<MovimientoPresupuesto> _movimientos = [];
  List<Etiqueta> _etiquetas = [];
  bool _cargando = true;
  bool get _esEditable =>
      _presupuesto!.mes == DateTime.now().month.toString() &&
      _presupuesto!.anio == DateTime.now().year.toString();
  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);
  final _fmtMiles = NumberFormat('#,##0', 'es_MX');
  int _diasTrabajadosHastaHoy = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _cargarDatos();
  }

// Agrega este helper en la clase
  void _limpiarYSalir() {
    if (!mounted) return;
    setState(() {
      _presupuesto = null; // ← esto activa el mensaje "sin presupuesto"
      _movimientos = [];
      _cargando = false;
    });
  }
  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    final mes = _fechaNav.month.toString();
    final anio = _fechaNav.year.toString();
    final ahora = DateTime.now();

    // ── Validación mes futuro ─────────────────────────────────────
    final esFuturo = _fechaNav.year > ahora.year ||
        (_fechaNav.year == ahora.year && _fechaNav.month > ahora.month);

    if (esFuturo) {
      // if (mounted) setState(() => _cargando = false);
      _limpiarYSalir();
      return;
    }

    // Cargar etiquetas del turnero
    final etiquetas = await _bd.getEtiquetas();

    // Buscar presupuesto del mes
    var presupuesto = await _bd.getPresupuestoMensual(mes, anio);

    // ── Si no existe ──────────────────────────────────────────────
    if (presupuesto == null) {
      final esMesActual =
          _fechaNav.month == ahora.month && _fechaNav.year == ahora.year;

      // Mes pasado sin presupuesto — mostrar vacío sin crear
      if (!esMesActual) {
        // if (mounted) setState(() => _cargando = false);
        _limpiarYSalir();

        return;
      }

      // Mes actual — verificar plantilla antes de crear
      final plantilla = await _bd.getPlantilla();
      if (plantilla.isEmpty) {
        if (mounted) {
          setState(() => _cargando = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF0F1923), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primero configura tu plantilla de presupuesto en Perfil',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0F1923)),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF5C518),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(
                label: 'Ir a plantilla',
                textColor: const Color(0xFF0F1923),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PlantillaPresupuestoScreen()),
                ),
              ),
            ),
          );
          _limpiarYSalir();
        }
        return;
      }

      // Plantilla existe — crear presupuesto del mes actual
      presupuesto = await _bd.crearPresupuestoDesdePlantilla(
        mes,
        anio,
        etiquetasContables: etiquetas
            .where((e) => e.nombre == 'Taxi' || e.nombre == 'Plataforma')
            .map((e) => e.nombre)
            .toList(),
      );

      // Si falló la creación — salir
      if (presupuesto == null) {
        if (mounted) setState(() => _cargando = false);
        return;
      }
    }

    // ── Sincronización de ítems nuevos de plantilla ───────────────
    // Solo si el mes está abierto
    if (presupuesto.estaAbierto) {
      await _bd.sincronizarItemsConPlantilla(presupuesto.id);

      // Verificar si hubo cambios para recargar
      final plantillaActual = await _bd.getPlantilla();
      final nombresActuales = presupuesto.items.map((i) => i.nombre).toSet();
      final hayNuevos =
          plantillaActual.any((p) => !nombresActuales.contains(p.nombre));

      if (hayNuevos) {
        presupuesto = await _bd.getPresupuestoMensual(mes, anio);
        if (presupuesto == null) {
          if (mounted) setState(() => _cargando = false);
          return;
        }
      }
    }

    // ── Cargar movimientos ────────────────────────────────────────
    final movimientos = await _bd.getMovimientosMes(presupuesto.id);

    // ── Calcular días planificados desde turnero ──────────────────
    final turnos = await _bd.getTurnosMes(_fechaNav.month, _fechaNav.year);

    final diasPlanificados = turnos
        .where(
            (t) => presupuesto!.etiquetasContables.contains(t.etiquetaNombre))
        .map((t) => t.fecha)
        .toSet()
        .length;

    final hoy = DateTime.now();
    final diasTrabajadosHastaHoy = turnos
        .where((t) =>
            presupuesto!.etiquetasContables.contains(t.etiquetaNombre) &&
            DateTime.parse(t.fecha)
                .isBefore(DateTime(hoy.year, hoy.month, hoy.day + 1)))
        .map((t) => t.fecha)
        .toSet()
        .length;

    // ── Actualizar días si cambiaron ──────────────────────────────
    if (diasPlanificados != presupuesto.diasPlanificados) {
      await _bd.actualizarConfigPresupuesto(
        presupuestoId: presupuesto.id,
        ahorroAnterior: presupuesto.ahorroAnterior,
        diasPlanificados: diasPlanificados,
        etiquetasContables: presupuesto.etiquetasContables,
      );
      presupuesto = await _bd.getPresupuestoMensual(mes, anio);
    }
    presupuesto?.items.sort((a, b) => b.plan.compareTo(a.plan));
    if (!mounted) return;
    setState(() {
      _presupuesto = presupuesto;
      _movimientos = movimientos;
      _etiquetas = etiquetas;
      _diasTrabajadosHastaHoy = diasTrabajadosHastaHoy;
      _cargando = false;
    });
  }

  void _cambiarMes(int delta) {
    setState(() {
      _fechaNav = DateTime(_fechaNav.year, _fechaNav.month + delta);
    });
    _cargarDatos();
  }

  String _nombreMes(int mes) {
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
    return meses[mes - 1];
  }

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    //if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  // ── Editar real de un ítem ────────────────────────────────────────────────────

  Future<void> _editarReal(PresupuestoItem item) async {
    final ctrl = TextEditingController(); // ← siempre en cero

    final abono = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: _C.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(item.nombre,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
            const SizedBox(height: 4),
            // Muestra el real acumulado actual
            Row(
              children: [
                Text('Acumulado: ${_fmt.format(item.real)}',
                    style: const TextStyle(fontSize: 11, color: _C.secondary)),
                const SizedBox(width: 8),
                Text('Plan: ${_fmt.format(item.plan)}',
                    style: const TextStyle(fontSize: 11, color: _C.primary)),
              ],
            ),
            const SizedBox(height: 14),
            // Label del campo
            const Text('Nuevo abono',
                style: TextStyle(fontSize: 10, color: _C.secondary)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.accent.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                    color: _C.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: '0', // ← siempre en cero
                  hintStyle: TextStyle(color: _C.primary, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: _C.accent, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Preview del nuevo total
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: ctrl,
              builder: (_, value, __) {
                final abono = int.tryParse(value.text.replaceAll(',', "")) ?? 0;
                final nuevoTotal = item.real + abono;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _C.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.green.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nuevo total:',
                          style: TextStyle(fontSize: 10, color: _C.secondary)),
                      Text(
                        _fmt.format(nuevoTotal),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _C.green),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                final raw = ctrl.text.trim();
                if (raw.isEmpty || int.parse(raw) <= 0) return;
                Navigator.pop(ctx, int.parse(raw));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Registrar abono',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F1923))),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (abono == null || _presupuesto == null) return;

    // Optimistic UI — actualizar en memoria inmediatamente

    // Firebase en background con batch
    await _bd.actualizarRealItem(
      presupuestoId: _presupuesto!.id,
      itemId: item.id,
      itemNombre: item.nombre,
      abonoNuevo: abono, // ← solo el abono
      realActual: item.real, // ← real antes del abono
    );

    // Recargar para sincronizar historial
    await _cargarDatos();
  }

  // ── Editar configuración ──────────────────────────────────────────────────────

  Future<void> _editarConfig() async {
    if (_presupuesto == null) return;
    final ctrlAhorro = TextEditingController(
        text: _presupuesto!.ahorroAnterior > 0
            ? _presupuesto!.ahorroAnterior.toString()
            : '');

    final etiquetasSeleccionadas =
        List<String>.from(_presupuesto!.etiquetasContables);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Configuración',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.primary)),
              const SizedBox(height: 14),
              // Ahorro anterior
              const Text('Ahorro mes anterior',
                  style: TextStyle(fontSize: 10, color: _C.secondary)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.cardBorder),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: ctrlAhorro,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MilesInputFormatter(_fmtMiles),
                  ],
                  style: const TextStyle(color: _C.primary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: _C.primary),
                    border: InputBorder.none,
                    isDense: true,
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(color: _C.accent),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Etiquetas contables
              const Text('Etiquetas que cuentan como días laborables',
                  style: TextStyle(fontSize: 10, color: _C.secondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _etiquetas.map((e) {
                  final color = Color(
                      int.parse('FF${e.color.replaceAll('#', '')}', radix: 16));
                  final isSelected = etiquetasSeleccionadas.contains(e.nombre);
                  return GestureDetector(
                    onTap: () => setModal(() {
                      if (isSelected) {
                        etiquetasSeleccionadas.remove(e.nombre);
                      } else {
                        etiquetasSeleccionadas.add(e.nombre);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : _C.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(e.nombre,
                          style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? color : _C.secondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final ahorro = int.tryParse(ctrlAhorro.text) ?? 0;
                  await _bd.actualizarConfigPresupuesto(
                    presupuestoId: _presupuesto!.id,
                    ahorroAnterior: ahorro,
                    diasPlanificados: _presupuesto!.diasPlanificados,
                    etiquetasContables: etiquetasSeleccionadas,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    _cargarDatos();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _C.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Guardar',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F1923))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            _buildHeader(),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : _presupuesto == null
                      ? _buildSinPresupuesto()
                      : _buildContenido(),
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
      child: Column(
        children: [
          Row(
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _C.secondary, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Presupuesto mensual',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _C.primary)),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TurneroScreen()),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5C518).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: const Color(0xFFF5C518).withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.calendar_month_outlined,
                      color: Color(0xFFF5C518), size: 15),
                ),
              ),
              // Botón configuración
              GestureDetector(
                onTap: _editarConfig,
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _C.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _C.accent.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: _C.accent, size: 16),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _esEditable
                      ? _C.green.withOpacity(0.1)
                      : _C.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _esEditable
                        ? _C.green.withOpacity(0.3)
                        : _C.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _esEditable ? 'Abierto' : 'Cerrado',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: _esEditable ? _C.green : _C.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Navegación mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _cambiarMes(-1),
                child: const Icon(Icons.chevron_left,
                    color: _C.secondary, size: 22),
              ),
              Text(
                '${_nombreMes(_fechaNav.month)} ${_fechaNav.year}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.primary),
              ),
              GestureDetector(
                onTap: () => _cambiarMes(1),
                child: const Icon(Icons.chevron_right,
                    color: _C.secondary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sin plantilla ─────────────────────────────────────────────────────────────

  Widget _buildSinPlantilla() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              color: _C.primary, size: 48),
          SizedBox(height: 12),
          Text('Sin plantilla configurada',
              style: TextStyle(color: _C.secondary, fontSize: 13)),
          SizedBox(height: 4),
          Text('Configura tu plantilla desde Perfil',
              style: TextStyle(color: _C.primary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSinPresupuesto() {
    final ahora = DateTime.now();
    final esFuturo = _fechaNav.year > ahora.year ||
        (_fechaNav.year == ahora.year && _fechaNav.month > ahora.month);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            esFuturo
                ? Icons.calendar_today_outlined
                : Icons.account_balance_wallet_outlined,
            color: _C.muted,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            esFuturo
                ? 'Este mes aún no está disponible'
                : 'Sin presupuesto registrado',
            style: const TextStyle(color: _C.secondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            esFuturo
                ? 'Se creará automáticamente al cerrar el mes anterior'
                : 'No hay datos para este período',
            style: const TextStyle(color: _C.muted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Contenido principal ───────────────────────────────────────────────────────

  Widget _buildContenido() {
    final p = _presupuesto!;
    final desfase = _presupuesto!.calcularDesfase(_diasTrabajadosHastaHoy);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      children: [
        if (desfase > 0 && _esEditable) ...[
          _buildAlertaDesfase(desfase),
          const SizedBox(height: 10),
        ],
        _buildHeroResumen(p),
        const SizedBox(height: 10),
        _buildTablaItems(p),
        const SizedBox(height: 10),
        _buildResultado(p),
        if (_movimientos.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildHistorial(),
        ],
        if (_esEditable) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: _C.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _C.cardBorder),
                  ),
                  title: const Text('¿Cerrar mes?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _C.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  content: Text(
                    'Se cerrará ${_nombreMes(_fechaNav.month)} ${_fechaNav.year} '
                    'y se creará el siguiente mes automáticamente.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _C.secondary, fontSize: 12),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cerrar mes',
                          style: TextStyle(color: _C.accent)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar',
                          style: TextStyle(color: _C.secondary)),
                    ),
                  ],
                ),
              );

              if (confirmar == true && mounted) {
                await _bd.cerrarMes(
                  _presupuesto!.id,
                  _presupuesto!.mes,
                  _presupuesto!.anio,
                );
                // Navegar al mes siguiente
                setState(() {
                  final sigMes = DateTime(_fechaNav.year, _fechaNav.month + 1);
                  _fechaNav = sigMes;
                });
                await _cargarDatos();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.accent.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, color: _C.accent, size: 15),
                  SizedBox(width: 8),
                  Text('Cerrar mes y abrir siguiente',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _C.accent)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertaDesfase(int desfase) {
    return Container(
      decoration: BoxDecoration(
        color: _C.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.red.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: _C.red, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Desfase detectado',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.red)),
                const SizedBox(height: 2),
                Text(
                  'Los días anteriores ahorraste menos de lo necesario. '
                  'Debes aportar ${_fmt.format(desfase)} adicionales '
                  'en los días restantes.',
                  style: const TextStyle(fontSize: 9, color: _C.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nueva meta ajustada: '
                  '${_fmt.format(_presupuesto!.metaDiaria + (desfase / (_presupuesto!.diasPlanificados - _diasTrabajadosHastaHoy).clamp(1, 99)).ceil())}/día',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w500, color: _C.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ── Hero resumen ──────────────────────────────────────────────────────────────

  Widget _buildHeroResumen(PresupuestoMensual p) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A55)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('META POR TURNO',
              style: TextStyle(
                  fontSize: 9, color: _C.secondary, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(_fmt.format(p.metaDiaria),
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w500, color: _C.accent)),
          const SizedBox(height: 10),
          // Métricas
          Row(
            children: [
              _heroMetrica(
                  'Total gastos', _fmt.format(p.totalPlan), _C.primary),
              _heroMetrica(
                  'Ahorro ant.', _fmt.format(p.ahorroAnterior), _C.green),
              _heroMetrica('Total a Cubrir',
                  _fmt.format(p.totalPlan - p.ahorroAnterior), _C.red),
              _heroMetrica('Días plan.', '${p.diasPlanificados}', _C.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetrica(String label, String valor, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: _C.primary)),
            const SizedBox(height: 2),
            Text(valor,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  // ── Tabla items ───────────────────────────────────────────────────────────────

  Widget _buildTablaItems(PresupuestoMensual p) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Column(
        children: [
          // Header tabla
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('ITEM',
                      style: TextStyle(
                          fontSize: 9, color: _C.primary, letterSpacing: 0.3)),
                ),
                Expanded(
                  child: Text('PLAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9, color: _C.primary, letterSpacing: 0.3)),
                ),
                Expanded(
                  child: Text('REAL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9, color: _C.primary, letterSpacing: 0.3)),
                ),
                Expanded(
                  child: Text('DIF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9, color: _C.primary, letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
          const Divider(color: _C.cardBorder, height: 1),
          // Items
          ...p.items.map((item) => _buildItemRow(item)),
          // Total
          const Divider(color: _C.cardBorder, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('TOTAL',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _C.primary)),
                ),
                Expanded(
                  child: Text(
                    _fmt.format(p.totalPlan),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _C.primary),
                  ),
                ),
                Expanded(
                  child: Text(
                    _fmt.format(p.totalReal),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _C.green),
                  ),
                ),
                Expanded(
                  child: Text(
                    _fmt.format(p.totalPlan - p.totalReal),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _C.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(PresupuestoItem item) {
    final difColor = item.diferencia >= 0 ? _C.green : _C.red;
    return GestureDetector(
      onTap: _esEditable ? () => _editarReal(item) : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: _C.cardBorder.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.pagado ? _C.green : _C.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.nombre,
                        style: const TextStyle(fontSize: 10, color: _C.primary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                _fmt.format(item.plan),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: _C.secondary),
              ),
            ),
            Expanded(
              child: Text(
                item.real > 0 ? _fmt.format(item.real) : '—',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: item.real > 0 ? _C.green : _C.primary,
                  fontWeight:
                      item.real > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _fmt.format(item.diferencia.abs()),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, color: difColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Resultado ─────────────────────────────────────────────────────────────────

  Widget _buildResultado(PresupuestoMensual p) {
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
          const Text('RESULTADO',
              style: TextStyle(
                  fontSize: 9, color: _C.secondary, letterSpacing: 0.4)),
          const SizedBox(height: 10),
          _resultadoFila(
              'Total a cubrir', _fmt.format(p.totalPlan), _C.primary),
          _resultadoFila('Gastado actual', _fmt.format(p.totalReal), _C.red),
          const Divider(color: _C.cardBorder, height: 16),
          _resultadoFila('Ahorro (Dif + Ahorro ant.)',
              _fmt.format(p.ahorroMes + p.ahorroAnterior), _C.green,
              destacado: true),
        ],
      ),
    );
  }

  Widget _resultadoFila(String label, String valor, Color color,
      {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: destacado ? 12 : 11,
                  fontWeight: destacado ? FontWeight.w500 : FontWeight.normal,
                  color: destacado ? _C.primary : _C.secondary)),
          Text(valor,
              style: TextStyle(
                  fontSize: destacado ? 13 : 11,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }

  // ── Historial movimientos ─────────────────────────────────────────────────────

  Widget _buildHistorial() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HISTORIAL DE PAGOS',
                  style: TextStyle(
                      fontSize: 9, color: _C.secondary, letterSpacing: 0.4)),
              Text('${_movimientos.length} registros',
                  style: const TextStyle(fontSize: 9, color: _C.accent)),
            ],
          ),
          const SizedBox(height: 10),
          ..._movimientos.map((mov) => _buildMovimientoItem(mov)),
        ],
      ),
    );
  }

  Widget _buildMovimientoItem(MovimientoPresupuesto mov) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: _C.green, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mov.itemNombre,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.primary)),
                Text('${mov.fecha} · ${mov.hora}',
                    style: const TextStyle(fontSize: 9, color: _C.secondary)),
              ],
            ),
          ),
          Text(_fmt.format(mov.valor),
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500, color: _C.green)),
          const SizedBox(width: 8),
          // Botón eliminar abono
          if (_esEditable)
            GestureDetector(
              onTap: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: _C.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: _C.cardBorder),
                    ),
                    title: const Text('¿Eliminar abono?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _C.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    content: Text(
                      'Se revertirán ${_fmt.format(mov.valor)} '
                      'del real de "${mov.itemNombre}".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _C.secondary, fontSize: 12),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: _C.red)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar',
                            style: TextStyle(color: _C.secondary)),
                      ),
                    ],
                  ),
                );

                if (confirmar == true && _presupuesto != null) {
                  // Buscar el item correspondiente
                  final item = _presupuesto!.items.firstWhere(
                      (i) => i.nombre == mov.itemNombre,
                      orElse: () => throw Exception('Item no encontrado'));

                  await _bd.eliminarAbono(
                    presupuestoId: _presupuesto!.id,
                    itemId: item.id,
                    movimientoId: mov.id,
                    valorAbono: mov.valor,
                    realActual: item.real,
                  );

                  await _cargarDatos();
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _C.red, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}
