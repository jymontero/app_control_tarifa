// ignore: file_names
// ignore_for_file: unused_element, prefer_final_fields, unused_field
import 'package:slide_action/slide_action.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_finturno/finish_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/editservicio_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/registroservicio_screen.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const headerBg = Color(0xFF0D1F2D);
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

class GoalDairy extends StatefulWidget {
  const GoalDairy({super.key});

  @override
  State<GoalDairy> createState() => _GoalDairyState();
}

class _GoalDairyState extends State<GoalDairy> {
  final _bd = FireStoreDataBase();
  List<Servicio> _listaServicios = [];
  bool _cargando = true;

  final _fmt = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarServiciosHoy();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _cargarServiciosHoy() async {
    final today = DateTime.now().toLocal();
    final fecha = '${today.day}-${today.month}-${today.year}';
    final lista = await _bd.getModeloServicios(fecha);

    // Ordenar por hora
    lista.sort((a, b) =>
        DateFormat.jm().parse(a.hora).compareTo(DateFormat.jm().parse(b.hora)));

    if (!mounted) return;
    setState(() {
      _listaServicios = lista;
      _cargando = false;
    });

    Future.microtask(() {
      if (!mounted) return;
      context.read<ContadorServicioProvider>().setNumeroServicios(lista.length);
    });
  }

  Future<void> _eliminarServicio(Servicio servicio) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text(
          '¿Eliminar servicio?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _C.primary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí', style: TextStyle(color: _C.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: _C.secondary)),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await _bd.eliminarServicio(servicio.id);
      if (!mounted) return;
      Future.microtask(() {
        context
            .read<ContadorServicioProvider>()
            .decrementarMetaObtendia(servicio.valorservicio);
        context
            .read<ContadorServicioProvider>()
            .sumarMetaPorHacer(servicio.valorservicio);
      });
      await _cargarServiciosHoy();
    }
  }

  void _mostrarAlertaFacturada() {
    QuickAlert.show(
      context: context,
      title: 'Servicio Facturado',
      text: 'No se puede modificar su valor',
      autoCloseDuration: const Duration(seconds: 5),
      confirmBtnText: 'OK',
      type: QuickAlertType.warning,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _compacto(int valor) {
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}k';
    return valor.toString();
  }

  Color _colorMetodoPago(String metodo) =>
      metodo == 'transferencia' ? Colors.purpleAccent.shade100 : _C.green;

  // ── Build principal ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(),
            _buildMetricsRow(),
            const SizedBox(height: 12),
            // _buildBotonRegistrar(),
            const SizedBox(height: 12),
            _buildHistorialHeader(),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : _listaServicios.isEmpty
                      ? _buildEstadoVacio()
                      : _buildListaServicios(),
            ),
            _buildBotonesInferiores(),
          ],
        ),
      ),
    );
  }

  // ── Hero card ────────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Consumer2<ContadorServicioProvider, ConfiguracionProvider>(
      builder: (_, contador, config, __) {
        final pct = contador.porcentajeMeta;
        final meta = config.metaRegistradaBD;
        final obtenido = contador.valorMetaObtenida;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 14, 12, 0),
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
                'RECAUDADO HOY',
                style: TextStyle(
                  fontSize: 10,
                  color: _C.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt.format(obtenido),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation(_C.accent),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${pct.toStringAsFixed(0)}% de la meta',
                    style: const TextStyle(fontSize: 9, color: _C.accent),
                  ),
                  Text(
                    'Meta: ${_fmt.format(meta)}',
                    style: const TextStyle(fontSize: 9, color: _C.secondary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Métricas ─────────────────────────────────────────────────────────────────

  Widget _buildMetricsRow() {
    return Consumer<ContadorServicioProvider>(
      builder: (_, contador, __) {
        final porHacer = contador.configuracion;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          decoration: BoxDecoration(
            color: _C.metricBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.cardBorder),
          ),
          child: Row(
            children: [
              _metricItem(
                label: 'Servicios',
                value: '${contador.numeroServiciosTotal}',
                color: _C.primary,
                hasBorder: true,
              ),
              _metricItem(
                label: 'Promedio',
                value: '\$${_compacto(contador.promedioPorServicio)}',
                color: _C.primary,
                hasBorder: true,
              ),
              _metricItem(
                label: 'Por hacer',
                value: '\$${_compacto(porHacer < 0 ? 0 : porHacer)}',
                color: porHacer <= 0 ? _C.green : _C.red,
                hasBorder: false,
              ),
            ],
          ),
        );
      },
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
                    fontSize: 14, fontWeight: FontWeight.w500, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: _C.secondary)),
          ],
        ),
      ),
    );
  }

  // ── Botón registrar ──────────────────────────────────────────────────────────

  Widget _buildBotonRegistrar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistroServicio()),
          );
          if (mounted) {
            setState(() => _cargando = true); // ← muestra loading brevemente
            await _cargarServiciosHoy();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _C.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Color(0xFF0F1923), size: 16),
              SizedBox(width: 8),
              Text(
                'Registrar nuevo servicio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F1923),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Historial header ──────────────────────────────────────────────────────────

  Widget _buildHistorialHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Historial del turno',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.primary,
            ),
          ),
          Text(
            '${_listaServicios.length} servicios',
            style: const TextStyle(fontSize: 10, color: _C.accent),
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────────────────────

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_taxi_outlined, color: _C.primary, size: 48),
          SizedBox(height: 12),
          Text(
            'Sin servicios registrados hoy',
            style: TextStyle(color: _C.secondary, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Toca el botón amarillo para agregar',
            style: TextStyle(color: _C.secondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Lista de servicios ────────────────────────────────────────────────────────

  Widget _buildListaServicios() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _listaServicios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final s = _listaServicios[index];
        return _buildServicioItem(s, index + 1);
      },
    );
  }

  Widget _buildServicioItem(Servicio s, int numero) {
    final colorPago = _colorMetodoPago(s.metodoPago);

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: _C.accent,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servicio #$numero',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      s.hora,
                      style: const TextStyle(fontSize: 9, color: _C.secondary),
                    ),
                    const SizedBox(width: 6),
                    // Badge tipo servicio
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _C.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        s.tipoServicio == 'plataforma' ? 'Plataforma' : 'Taxi',
                        style: const TextStyle(fontSize: 8, color: _C.accent),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Badge método pago
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorPago.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        s.metodoPago == 'transferencia'
                            ? 'Transf.'
                            : 'Efectivo',
                        style: TextStyle(fontSize: 8, color: colorPago),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Monto
          Text(
            '+${_fmt.format(s.valorservicio)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.green,
            ),
          ),
          const SizedBox(width: 8),

          // Acciones editar / eliminar
          if (!s.facturada) ...[
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditService(s)),
                );
                _cargarServiciosHoy();
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _C.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child:
                    const Icon(Icons.edit_outlined, color: _C.accent, size: 14),
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => _eliminarServicio(s),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child:
                    const Icon(Icons.delete_outline, color: _C.red, size: 14),
              ),
            ),
          ] else ...[
            // Servicio facturado — solo ícono de advertencia
            GestureDetector(
              onTap: _mostrarAlertaFacturada,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _C.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.lock_outline,
                    color: _C.secondary, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Finalizar turno ──────────────────────────────────────────────────────────

  // Widget _buildFinalizarTurno() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12, 6, 80, 18),
  //     child: GestureDetector(
  //       onTap: () async {
  //         final confirmar = await showDialog<bool>(
  //           context: context,
  //           builder: (ctx) => AlertDialog(
  //             backgroundColor: _C.cardBg,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //               side: const BorderSide(color: _C.cardBorder),
  //             ),
  //             title: const Text(
  //               '¿Finalizar turno?',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: _C.primary,
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             actionsAlignment: MainAxisAlignment.spaceEvenly,
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx, true),
  //                 child: const Text('Sí', style: TextStyle(color: _C.accent)),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx, false),
  //                 child:
  //                     const Text('No', style: TextStyle(color: _C.secondary)),
  //               ),
  //             ],
  //           ),
  //         );

  //         if (confirmar == true && mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (_) => StepperFinalized()),
  //           );
  //         }
  //       },
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //         decoration: BoxDecoration(
  //           color: _C.red.withOpacity(0.25),
  //           borderRadius: BorderRadius.circular(14),
  //           border: Border.all(color: _C.red.withOpacity(0.2)),
  //         ),
  //         child: const Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(Icons.output_outlined, color: _C.red, size: 16),
  //             SizedBox(width: 8),
  //             Text(
  //               'Finalizar turno',
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w500,
  //                 color: _C.red,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildBotonesInferiores() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: _C.bg,
        border: Border(top: BorderSide(color: _C.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Registrar servicio — acción principal
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroServicio()),
              );
              if (mounted) {
                setState(() => _cargando = true);
                await _cargarServiciosHoy();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF0F1923), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Registrar nuevo servicio',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),

          SlideAction(
            trackHeight: 50,
            trackBuilder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.red.withOpacity(0.2)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: _C.red.withOpacity(
                          1.0 - state.thumbFractionalPosition,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Desliza para finalizar turno',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _C.red.withOpacity(
                            1.0 - state.thumbFractionalPosition,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            thumbBuilder: (context, state) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.red.withOpacity(0.4)),
                ),
                child: state.isPerformingAction
                    ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: _C.red,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.output_outlined,
                        color: _C.red,
                        size: 18,
                      ),
              );
            },
            action: () async {
              if (!mounted) return;
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: _C.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _C.cardBorder),
                  ),
                  title: const Text(
                    '¿Finalizar turno?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _C.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child:
                          const Text('Sí', style: TextStyle(color: _C.accent)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('No',
                          style: TextStyle(color: _C.secondary)),
                    ),
                  ],
                ),
              );
              if (confirmar == true && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StepperFinalized()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
