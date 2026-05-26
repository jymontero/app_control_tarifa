import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const headerBg = Color(0xFF0D1F2D);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFF87171);
  static const heroBorder = Color(0xFF1E3A55);
}

class RegistroServicio extends StatefulWidget {
  const RegistroServicio({super.key});

  @override
  State<RegistroServicio> createState() => _RegistroServicioState();
}

class _RegistroServicioState extends State<RegistroServicio> {
  // ── Estado ──────────────────────────────────────────────────────────────────
  final _controller = TextEditingController();
  final _db = FireStoreDataBase();

  DateTime _time = DateTime.now().toLocal();
  String _tipoServicio = 'taxi'; // 'taxi' | 'plataforma'
  String _metodoPago = 'efectivo'; // 'efectivo' | 'transferencia'

  // Fecha del turno: 0=ayer, 1=hoy
  int _fechaSeleccionada = 1;

  final _fmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  DateTime get _fechaTurno {
    if (_fechaSeleccionada == 0) {
      return _time.subtract(const Duration(days: 1));
    }
    return _time;
  }

  String get _fechaFormateada {
    final f = _fechaTurno;
    return '${f.day}-${f.month}-${f.year}';
  }

  String get _horaFormateada => DateFormat.jm().format(_time);

  int get _numeroServicio =>
      (_controller.text.isEmpty) ? 0 : 1; // referencial para el chip

  void _showAlertValor() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A2535),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 18),

                // Título
                const Text(
                  'Valor del servicio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // Texto
                const Text(
                  'Ingrese un valor mayor a\nCOP \$0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5C518),
                      foregroundColor: const Color(0xFF0F1923),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto cerrar en 3 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  // ── Guardar ──────────────────────────────────────────────────────────────────

  Future<void> _guardarServicio() async {
    final raw = _controller.text.replaceAll(',', '');
    if (raw.isEmpty || int.parse(raw) <= 0) {
      _showAlertValor();
      return;
    }

    final valor = int.parse(raw);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: Column(
          children: [
            const Text(
              '¿Registrar servicio?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _C.primary, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              _fmt.format(valor),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _C.accent, fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí', style: TextStyle(color: _C.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: _C.secondary)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      // Actualizar providers
      context.read<ContadorServicioProvider>().incrementarMetaObtenida(valor);
      context.read<ContadorServicioProvider>().decrementarMetaPorHacer(valor);

      // Guardar en Firebase con nuevos campos
      await _db.addServicioBD(
        _fechaFormateada,
        _horaFormateada,
        valor,
        false,
        _tipoServicio,
        _metodoPago,
      );

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustomized(),
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTitulo(),
              const SizedBox(height: 16),
              _buildToggleTipoServicio(),
              const SizedBox(height: 10),
              _buildToggleMetodoPago(),
              const SizedBox(height: 10),
              _buildCampoValor(),
              const SizedBox(height: 10),
              _buildHoraAutomatica(),
              const SizedBox(height: 10),
              _buildSelectorFecha(),
              const SizedBox(height: 14),
              _buildChipResumen(),
              const SizedBox(height: 14),
              _buildBotonGuardar(),
              const SizedBox(height: 8),
              _buildBotonCancelar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildTitulo() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child:
              const Icon(Icons.local_taxi_rounded, color: _C.accent, size: 16),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registro de servicio',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
            Text('Completa los datos del viaje',
                style: TextStyle(fontSize: 10, color: _C.secondary)),
          ],
        ),
      ],
    );
  }

  // ── Toggle genérico ──────────────────────────────────────────────────────────

  Widget _buildToggle({
    required String label,
    required List<String> opciones,
    required List<String> etiquetas,
    required List<IconData> iconos,
    required String seleccionado,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: List.generate(opciones.length, (i) {
              final isActive = seleccionado == opciones[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opciones[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? _C.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      border:
                          isActive ? null : Border.all(color: _C.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconos[i],
                            size: 13,
                            color: isActive
                                ? const Color(0xFF0F1923)
                                : _C.secondary),
                        const SizedBox(width: 5),
                        Text(
                          etiquetas[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF0F1923)
                                : _C.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTipoServicio() {
    return _buildToggle(
      label: 'Tipo de servicio',
      opciones: ['taxi', 'plataforma'],
      etiquetas: ['Taxi', 'Plataforma'],
      iconos: [Icons.local_taxi_rounded, Icons.phone_android_outlined],
      seleccionado: _tipoServicio,
      onChanged: (v) => setState(() => _tipoServicio = v),
    );
  }

  Widget _buildToggleMetodoPago() {
    return _buildToggle(
      label: 'Método de pago',
      opciones: ['efectivo', 'transferencia'],
      etiquetas: ['Efectivo', 'Transferencia'],
      iconos: [Icons.payments_outlined, Icons.swap_horiz_rounded],
      seleccionado: _metodoPago,
      onChanged: (v) => setState(() => _metodoPago = v),
    );
  }

  Widget _buildCampoValor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valor del servicio',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_outlined,
                  color: _C.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: _C.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Ingrese el valor COP',
                    hintStyle: TextStyle(color: _C.secondary, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoraAutomatica() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hora del viaje',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded, color: _C.accent, size: 14),
              const SizedBox(width: 8),
              Text(
                _horaFormateada,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              const Spacer(),
              const Text('Automática',
                  style: TextStyle(fontSize: 9, color: _C.secondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorFecha() {
    final ayer = _time.subtract(const Duration(days: 1));
    final hoy = _time;

    final opciones = [
      {
        'label': 'Ayer',
        'fecha': '${ayer.day} ${_mesCorto(ayer.month)}',
        'idx': 0
      },
      {'label': 'Hoy', 'fecha': '${hoy.day} ${_mesCorto(hoy.month)}', 'idx': 1},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha del turno',
            style: TextStyle(fontSize: 10, color: _C.secondary)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              ...opciones.map((o) {
                final idx = o['idx'] as int;
                final isActive = _fechaSeleccionada == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _fechaSeleccionada = idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? _C.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border:
                            isActive ? null : Border.all(color: _C.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            o['label'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF0F1923)
                                  : _C.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            o['fecha'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF0F1923)
                                  : _C.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Mañana — deshabilitado
              Expanded(
                child: Opacity(
                  opacity: 0.25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _C.cardBorder),
                    ),
                    child: Column(
                      children: [
                        const Text('Mañana',
                            style: TextStyle(fontSize: 9, color: _C.secondary)),
                        const SizedBox(height: 2),
                        Text(
                          '${hoy.add(const Duration(days: 1)).day} ${_mesCorto(hoy.add(const Duration(days: 1)).month)}',
                          style: const TextStyle(
                              fontSize: 10, color: _C.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.info_outline, color: _C.accent, size: 11),
            const SizedBox(width: 4),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 9, color: _C.secondary),
                children: [
                  TextSpan(text: 'Si tu turno pasó de medianoche selecciona '),
                  TextSpan(
                    text: 'Ayer',
                    style: TextStyle(color: _C.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipResumen() {
    final raw = _controller.text.replaceAll(',', '');
    final tieneValor = raw.isNotEmpty && int.tryParse(raw) != null;

    return Container(
      decoration: BoxDecoration(
        color: _C.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.accent.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tieneValor
                ? '${_fechaSeleccionada == 0 ? "Ayer" : "Hoy"} · $_horaFormateada'
                : 'Completa los campos',
            style: const TextStyle(fontSize: 9, color: _C.secondary),
          ),
          Row(
            children: [
              _chipBadge(
                _tipoServicio == 'taxi' ? 'Taxi' : 'Plataforma',
                _C.accent,
              ),
              const SizedBox(width: 6),
              _chipBadge(
                _metodoPago == 'efectivo' ? 'Efectivo' : 'Transf.',
                _C.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipBadge(String texto, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 3),
        Text(texto, style: TextStyle(fontSize: 9, color: color)),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return GestureDetector(
      onTap: _guardarServicio,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _C.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Color(0xFF0F1923), size: 16),
            SizedBox(width: 8),
            Text(
              'Agregar viaje',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F1923),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCancelar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardBorder),
        ),
        child: const Center(
          child: Text('Cancelar',
              style: TextStyle(fontSize: 12, color: _C.secondary)),
        ),
      ),
    );
  }

  // ── Utilidades ───────────────────────────────────────────────────────────────

  String _mesCorto(int mes) {
    const meses = [
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
    return meses[mes - 1];
  }
}
