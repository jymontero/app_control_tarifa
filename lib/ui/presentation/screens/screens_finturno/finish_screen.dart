import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/registrylavada_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/registryentrega_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_tanqueo/registrocombustible_screen.dart';

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
}

class StepperFinalized extends StatefulWidget {
  const StepperFinalized({super.key});

  @override
  State<StepperFinalized> createState() => _StepperFinalizedState();
}

class _StepperFinalizedState extends State<StepperFinalized> {
  final FireStoreDataBase _db = FireStoreDataBase();
  List<int> _listaControlGanancia = [];
  int numServiciosF = 0;
  int _currentStep = 0;
  DateTime _selectedDate = DateTime.now().toLocal();
  bool _loadingFinish = false;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    Future.microtask(() =>
        context.read<ContadorServicioProvider>().setearMetaObtenidaFinish(0));
    _cargarServiciosHoy();
  }

  void _cargarServiciosHoy() {
    final fecha =
        '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}';
    _getDataServiciosToday(fecha);
  }

  void _getDataServiciosToday(String date) async {
    List<Servicio> listaServicio = await _db.getModeloServicios(date);
    if (listaServicio.isNotEmpty && mounted) {
      numServiciosF = listaServicio.length;
      Future.microtask(() => context
          .read<ContadorServicioProvider>()
          .sumarListaServiciosBD(listaServicio, 'FINISH'));
    }
  }

  // ── Guardar turno ─────────────────────────────────────────────────────────────

  Future<void> _guardarTurno(ServicioTanqueoProvider tanqueo) async {
    final serviciosProvider =
        Provider.of<ContadorServicioProvider>(context, listen: false);

    final int ganancia = serviciosProvider.metaObtenidaFinish;
    final int totalBruto = serviciosProvider.valorBruto;
    // final int numServicios = serviciosProvider.numeroServiciosTotal;
    final int numServicios = numServiciosF;
    final int valorTanqueo =
        int.parse(tanqueo.valorTanqueo.replaceAll(',', ''));
    final int valorEntrega =
        int.parse(tanqueo.valorEntrega.replaceAll(',', ''));
    final int valorLavada = int.parse(tanqueo.valorLavada.replaceAll(',', ''));
    final int deducciones = valorTanqueo + valorEntrega + valorLavada;
    final double valorGalones =
        double.parse(tanqueo.valorGalones.replaceAll(',', '.'));
    final int valorKilometros = int.parse(tanqueo.valorKilometros);

    // Guardar ganancia con desglose completo
    await _db.addGananciaBD(
      ganancia,
      _selectedDate.day.toString(),
      _selectedDate.month.toString(),
      _selectedDate.year.toString(),
      totalBruto: totalBruto,
      deducciones: deducciones,
      numServicios: numServicios,
    );

    // Guardar tanqueo
    await _db.addTanqueoBD(
      valorTanqueo,
      valorKilometros,
      valorGalones,
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      '${_selectedDate.hour}:${_selectedDate.minute}:${_selectedDate.second}',
    );

    // Marcar servicios como facturados
    await _db.actualizarEstadoServicio(
        '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}');

    if (!mounted) return;
    _showAlertSuccess();
  }

  void _showAlertSuccess() {
    QuickAlert.show(
      context: context,
      title: 'Turno Finalizado',
      text: 'Buen Descanso',
      autoCloseDuration: const Duration(seconds: 5),
      confirmBtnText: 'OK',
      type: QuickAlertType.success,
      backgroundColor: const Color(0xFF1A2535), // ← fondo card oscuro
      titleColor: const Color(0xFFF1F5F9), // ← título blanco
      textColor: const Color(0xFF94A3B8), // ← texto secundario
      confirmBtnColor: const Color(0xFFF5C518), // ← botón amarillo
      confirmBtnTextStyle: const TextStyle(
        // ← texto botón oscuro
        color: Color(0xFF0F1923),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tanqueo = Provider.of<ServicioTanqueoProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildTotalBruto(),
                  const SizedBox(height: 14),
                  _buildProgresoDeducciones(),
                  const SizedBox(height: 14),
                  _buildStepper(tanqueo),
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
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Finalizar turno',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      locale: const Locale('es'),
                      initialDate: _selectedDate,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2030),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );
                    if (selected != null && selected != _selectedDate) {
                      setState(() {
                        _selectedDate = selected;
                        _cargarServiciosHoy();
                      });
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: _C.accent, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMEd('es').format(_selectedDate),
                        style: const TextStyle(fontSize: 10, color: _C.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Total bruto ───────────────────────────────────────────────────────────────

  Widget _buildTotalBruto() {
    return Consumer<ContadorServicioProvider>(
      builder: (_, contador, __) {
        return Container(
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
              const Text(
                'TOTAL BRUTO DEL DÍA',
                style: TextStyle(
                  fontSize: 10,
                  color: _C.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt.format(contador.valorBruto),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _infoChip(
                    '${contador.numeroServiciosTotal} servicios',
                    _C.accent,
                  ),
                  const SizedBox(width: 8),
                  _infoChip(
                    'Ganancia: ${_fmt.format(contador.metaObtenidaFinish)}',
                    _C.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoChip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(texto, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  // ── Progreso deducciones ──────────────────────────────────────────────────────

  Widget _buildProgresoDeducciones() {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Deducciones ingresadas',
            style: TextStyle(fontSize: 10, color: _C.secondary),
          ),
          Text(
            '$_currentStep de 3',
            style: const TextStyle(
                fontSize: 10, color: _C.accent, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Stepper ───────────────────────────────────────────────────────────────────

  Widget _buildStepper(ServicioTanqueoProvider tanqueo) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _C.accent,
          onPrimary: Color(0xFF0F1923),
          surface: _C.cardBg,
          onSurface: _C.primary,
        ),
        canvasColor: _C.bg,
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () => _onStepContinue(tanqueo),
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) => _buildControles(details),
        steps: _buildSteps(),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        title: Text(
          'Tanqueo',
          style: TextStyle(
            color: _currentStep >= 0 ? _C.primary : _C.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: RegistroCombustible(),
        ),
      ),
      Step(
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        title: Text(
          'Entrega',
          style: TextStyle(
            color: _currentStep >= 1 ? _C.primary : _C.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const SizedBox(
          width: 300,
          height: 100,
          child: RegistryEntrega(),
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        title: Text(
          'Lavada',
          style: TextStyle(
            color: _currentStep >= 2 ? _C.primary : _C.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const SizedBox(
          width: 300,
          height: 110,
          child: RegistryLavada(),
        ),
      ),
      Step(
        isActive: _currentStep >= 3,
        state: _currentStep >= 3 ? StepState.complete : StepState.indexed,
        title: Text(
          'Ganancias',
          style: TextStyle(
            color: _currentStep >= 3 ? _C.primary : _C.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Consumer<ContadorServicioProvider>(
          builder: (_, contador, __) => Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _resumenGanancias(contador),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _resumenGanancias(ContadorServicioProvider contador) {
    final tanqueo = Provider.of<ServicioTanqueoProvider>(context, listen: true);
    final valorTanqueo = tanqueo.valorTanqueo.isEmpty
        ? 0
        : int.tryParse(tanqueo.valorTanqueo.replaceAll(',', '')) ?? 0;
    final valorEntrega = tanqueo.valorEntrega.isEmpty
        ? 0
        : int.tryParse(tanqueo.valorEntrega.replaceAll(',', '')) ?? 0;
    final valorLavada = tanqueo.valorLavada.isEmpty
        ? 0
        : int.tryParse(tanqueo.valorLavada.replaceAll(',', '')) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _resumenFila(
              'Total bruto', _fmt.format(contador.valorBruto), _C.primary),
          const Divider(color: _C.cardBorder, height: 12),
          _resumenFila('Tanqueo', '- ${_fmt.format(valorTanqueo)}', _C.red),
          _resumenFila('Entrega', '- ${_fmt.format(valorEntrega)}', _C.red),
          _resumenFila('Lavada', '- ${_fmt.format(valorLavada)}', _C.red),
          const Divider(color: _C.cardBorder, height: 12),
          _resumenFila(
            'Ganancia neta',
            _fmt.format(contador.metaObtenidaFinish),
            _C.green,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _resumenFila(String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: _C.secondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 13 : 11,
              fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Controles stepper ─────────────────────────────────────────────────────────

  Widget _buildControles(ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: details.onStepContinue,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _currentStep == 3 ? 'Confirmar' : 'Continuar →',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_currentStep != 0) ...[
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: details.onStepCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.cardBorder),
                  ),
                  child: const Center(
                    child: Text(
                      '← Atrás',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _C.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Lógica pasos ─────────────────────────────────────────────────────────────

  void _onStepContinue(ServicioTanqueoProvider tanqueo) {
    if (_currentStep == 0) {
      final valor = int.parse(tanqueo.valorTanqueo.replaceAll(',', ''));
      context
          .read<ContadorServicioProvider>()
          .decrementarMetaObtenidaFinish(valor);
      _listaControlGanancia.add(valor);
    }

    if (_currentStep == 1) {
      final valor = int.parse(tanqueo.valorEntrega.replaceAll(',', ''));
      context
          .read<ContadorServicioProvider>()
          .decrementarMetaObtenidaFinish(valor);
      _listaControlGanancia.add(valor);
    }

    if (_currentStep == 2) {
      final valor = int.parse(tanqueo.valorLavada.replaceAll(',', ''));
      context
          .read<ContadorServicioProvider>()
          .decrementarMetaObtenidaFinish(valor);
      _listaControlGanancia.add(valor);
    }

    if (_currentStep == 3) {
      _guardarTurno(tanqueo);
      return;
    }

    setState(() => _currentStep++);
  }

  void _onStepCancel() {
    if (_currentStep <= 0) return;
    setState(() {
      _currentStep--;
      final restar = _listaControlGanancia.elementAt(_currentStep);
      _listaControlGanancia.removeAt(_currentStep);
      context
          .read<ContadorServicioProvider>()
          .incrementarMetaObtenidaFinish(restar);
    });
  }
}
