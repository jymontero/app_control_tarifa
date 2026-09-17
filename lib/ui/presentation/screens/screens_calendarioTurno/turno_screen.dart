import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/etiqueta.dart';
import 'package:taxi_servicios/domain/entitis/turno.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

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
}

// Colores predefinidos para etiquetas
const _coloresEtiqueta = [
  '#F5C518',
  '#60A5FA',
  '#4ADE80',
  '#F87171',
  '#A78BFA',
  '#FB923C',
  '#34D399',
  '#F472B6',
];

class TurneroScreen extends StatefulWidget {
  const TurneroScreen({super.key});

  @override
  State<TurneroScreen> createState() => _TurneroScreenState();
}

class _TurneroScreenState extends State<TurneroScreen> {
  final FireStoreDataBase _bd = FireStoreDataBase();

  DateTime _fechaNav = DateTime.now();
  List<Etiqueta> _etiquetas = [];
  List<Turno> _turnos = [];
  Etiqueta? _etiquetaActiva;
  bool _cargando = true;
  bool _modoEdicion = false;
  Map<String, List<Turno>> _turnosLocal = {}; // estado local en edición
  List<String> _turnosAEliminar = []; // ids a eliminar al guardar
  // Días con ingresos registrados (fechas en formato 'yyyy-MM-dd')
  Set<String> _diasTrabajados = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final etiquetas = await _bd.getEtiquetas();
    final turnos = await _bd.getTurnosMes(_fechaNav.month, _fechaNav.year);
    final ingresos = await _bd.getModeloIngresos(
        _fechaNav.month.toString(), _fechaNav.year.toString());

    if (!mounted) return;

    // Construir set de días trabajados
    final diasTrabajados = ingresos.map((i) {
      final mes = i.mes.padLeft(2, '0');
      final dia = i.dia.padLeft(2, '0');
      return '${i.anio}-$mes-$dia';
    }).toSet();

    setState(() {
      _etiquetas = etiquetas;
      _turnos = turnos;
      _diasTrabajados = diasTrabajados;
      _etiquetaActiva ??= etiquetas.isNotEmpty ? etiquetas.first : null;
      _cargando = false;
    });
  }

  void _cambiarMes(int delta) {
    setState(() {
      _fechaNav = DateTime(_fechaNav.year, _fechaNav.month + delta);
    });
    _cargarDatos();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _fechaStr(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  bool _esPasado(DateTime dia) {
    final hoy = DateTime.now();
    return dia.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
  }

  bool _esHoy(DateTime dia) {
    final hoy = DateTime.now();
    return dia.year == hoy.year && dia.month == hoy.month && dia.day == hoy.day;
  }

  List<Turno> _turnosDia(String fechaStr) =>
      _turnos.where((t) => t.fecha == fechaStr).toList();

  bool _trabajoEseDia(String fechaStr) => _diasTrabajados.contains(fechaStr);

  // Resumen del mes
  int get _diasTrabajadosMes => _diasTrabajados.length;
  int get _diasPlanificados {
    final hoy = DateTime.now();
    final fechasConTurno = _turnos.map((t) => t.fecha).toSet();
    return fechasConTurno.where((f) {
      final fecha = DateTime.parse(f);
      return fecha.isAfter(hoy) || _esHoy(fecha);
    }).length;
  }

  // ── Tap en día ───────────────────────────────────────────────────────────────

  Future<void> _onDiaTap(DateTime dia) async {
    final fechaStr = _fechaStr(dia);
    final esPasado = _esPasado(dia);
    final trabajado = _trabajoEseDia(fechaStr);

    if (esPasado && !trabajado) return;

    if (esPasado && trabajado) {
      _mostrarInfoDia(fechaStr, dia);
      return;
    }

    if (_etiquetaActiva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una etiqueta primero'),
          backgroundColor: Color(0xFF1A2535),
        ),
      );
      return;
    }

    if (_modoEdicion) {
      // ── Modo edición — solo modifica local ──
      final turnosDia = _turnosLocal[fechaStr] ?? [];
      final yaExiste =
          turnosDia.any((t) => t.etiquetaId == _etiquetaActiva!.id);

      if (yaExiste) {
        // Quitar etiqueta
        final turno =
            turnosDia.firstWhere((t) => t.etiquetaId == _etiquetaActiva!.id);
        if (turno.id.isNotEmpty) {
          _turnosAEliminar.add(turno.id);
        }
        setState(() {
          _turnosLocal[fechaStr] = turnosDia
              .where((t) => t.etiquetaId != _etiquetaActiva!.id)
              .toList();
        });
      } else {
        // Agregar etiqueta — id vacío porque aún no está en Firebase
        final nuevoTurno = Turno(
          fecha: fechaStr,
          etiquetaId: _etiquetaActiva!.id,
          etiquetaNombre: _etiquetaActiva!.nombre,
          etiquetaColor: _etiquetaActiva!.color,
        )..id = '';

        setState(() {
          _turnosLocal[fechaStr] = [...turnosDia, nuevoTurno];
        });
      }
    } else {
      if (!_modoEdicion) return;
      // ── Modo normal — escribe directo a Firebase ──
      // final turnosDia = _turnosDia(fechaStr);
      // final yaExiste =
      //     turnosDia.any((t) => t.etiquetaId == _etiquetaActiva!.id);

      // if (yaExiste) {
      //   final turno =
      //       turnosDia.firstWhere((t) => t.etiquetaId == _etiquetaActiva!.id);
      //   await _bd.eliminarTurno(turno.id);
      // } else {
      //   await _bd.addTurno(
      //     fecha: fechaStr,
      //     etiquetaId: _etiquetaActiva!.id,
      //     etiquetaNombre: _etiquetaActiva!.nombre,
      //     etiquetaColor: _etiquetaActiva!.color,
      //   );
      // }
      // await _cargarDatos();
    }
  }

  void _mostrarInfoDia(String fechaStr, DateTime dia) {
    final turnos = _turnosDia(fechaStr);
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _C.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '${dia.day} de ${_nombreMes(dia.month)} ${dia.year}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Día trabajado',
                style: TextStyle(fontSize: 10, color: _C.green)),
            const SizedBox(height: 12),
            if (turnos.isNotEmpty) ...[
              const Text('Etiquetas:',
                  style: TextStyle(fontSize: 10, color: _C.secondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: turnos.map((t) {
                  final color = Color(t.colorValue);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(t.etiquetaNombre,
                        style: TextStyle(fontSize: 11, color: color)),
                  );
                }).toList(),
              ),
            ] else
              const Text('Sin etiquetas asignadas',
                  style: TextStyle(fontSize: 10, color: _C.muted)),
          ],
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
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildResumenMes(),
                          _buildSelectorEtiquetas(),
                          _buildCalendario(),
                          _buildLeyenda(),
                          const SizedBox(height: 16),
                        ],
                      ),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mis turnos',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _C.primary)),
                  Text('Planificador de jornadas',
                      style: TextStyle(fontSize: 10, color: _C.secondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Navegación mes
          // Al final del Row de navegación de mes agrega:
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
          const SizedBox(height: 10),
// ← Agrega esto:
          if (_modoEdicion)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _cancelarEdicion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.cardBorder),
                      ),
                      child: const Center(
                        child: Text('Cancelar',
                            style:
                                TextStyle(fontSize: 11, color: _C.secondary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _guardarEdicion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _C.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Guardar cambios',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F1923))),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _entrarModoEdicion,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _C.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.accent.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, color: _C.accent, size: 13),
                      SizedBox(width: 6),
                      Text('Editar turnos',
                          style: TextStyle(
                              fontSize: 11,
                              color: _C.accent,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Resumen mes ───────────────────────────────────────────────────────────────

  Widget _buildResumenMes() {
    final confirmados = _confirmadosPorEtiqueta;
    final planificados = _planificadosPorEtiqueta;
    final hayContenido = confirmados.isNotEmpty || planificados.isNotEmpty;

    if (!hayContenido) return const SizedBox();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.cardBorder),
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmados
          if (confirmados.isNotEmpty) ...[
            const Text(
              'EJECUTADOS',
              style: TextStyle(
                fontSize: 9,
                color: _C.secondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            ...confirmados.entries.map((e) =>
                _resumenFila(e.key, e.value, _colorEtiqueta(e.key), true)),
          ],
          // Separador
          if (confirmados.isNotEmpty && planificados.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: _C.cardBorder, height: 1),
            const SizedBox(height: 8),
          ],
          // Planificados
          if (planificados.isNotEmpty) ...[
            const Text(
              'PLANIFICADOS',
              style: TextStyle(
                fontSize: 9,
                color: _C.secondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            ...planificados.entries.map((e) =>
                _resumenFila(e.key, e.value, _colorEtiqueta(e.key), false)),
          ],
        ],
      ),
    );
  }

  Widget _resumenFila(String nombre, int dias, Color color, bool confirmado) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Ícono estado
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              confirmado ? Icons.check_rounded : Icons.schedule_rounded,
              size: 11,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          // Nombre etiqueta
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          // Días
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              '$dias ${dias == 1 ? 'día' : 'días'}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenItem(String label, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: _C.secondary)),
          ],
        ),
      ),
    );
  }

  // ── Selector etiquetas ────────────────────────────────────────────────────────

  Widget _buildSelectorEtiquetas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Etiqueta activa',
              style: TextStyle(fontSize: 9, color: _C.secondary)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._etiquetas.map((e) {
                  final color = Color(
                      int.parse('FF${e.color.replaceAll('#', '')}', radix: 16));
                  final isActive = _etiquetaActiva?.id == e.id;
                  return GestureDetector(
                    onTap: () => setState(() => _etiquetaActiva = e),
                    onLongPress: () => _confirmarEliminarEtiqueta(e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? color : color.withOpacity(0.2),
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(e.nombre,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: isActive
                                      ? FontWeight.w500
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }),
                // Botón nueva etiqueta
                GestureDetector(
                  onTap: _mostrarCrearEtiqueta,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: _C.secondary, size: 12),
                        SizedBox(width: 4),
                        Text('Nueva',
                            style:
                                TextStyle(fontSize: 11, color: _C.secondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendario ────────────────────────────────────────────────────────────────

  Widget _buildCalendario() {
    final primerDia = DateTime(_fechaNav.year, _fechaNav.month, 1);
    final diasEnMes = DateTime(_fechaNav.year, _fechaNav.month + 1, 0).day;
    // Ajuste: lunes = 0
    final offsetInicio = (primerDia.weekday - 1) % 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          // Labels días semana
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _C.muted,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // Grid días
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: offsetInicio + diasEnMes,
            itemBuilder: (_, index) {
              if (index < offsetInicio) {
                return const SizedBox();
              }
              final dia = DateTime(
                  _fechaNav.year, _fechaNav.month, index - offsetInicio + 1);
              return _buildDia(dia);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDia(DateTime dia) {
    final fechaStr = _fechaStr(dia);
    final esPasado = _esPasado(dia);
    final esHoy = _esHoy(dia);
    final trabajado = _trabajoEseDia(fechaStr);
    final turnos = _turnosDiaActual(fechaStr); // ← usa helper nuevo

    return GestureDetector(
      onTap: () => _onDiaTap(dia),
      child: Container(
        decoration: BoxDecoration(
          color: esHoy ? _C.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: esHoy ? Border.all(color: _C.accent.withOpacity(0.4)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${dia.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: esHoy ? FontWeight.w600 : FontWeight.normal,
                color: esPasado && !trabajado
                    ? _C.muted
                    : esHoy
                        ? _C.accent
                        : _C.primary,
              ),
            ),
            // Etiquetas — nombre abreviado
            if (turnos.isNotEmpty || trabajado) ...[
              const SizedBox(height: 2),
              if (trabajado && turnos.isEmpty)
                const Text('trab.',
                    style: TextStyle(
                        fontSize: 8,
                        color: _C.green,
                        fontWeight: FontWeight.w500)),
              ...turnos.take(2).map((t) {
                final color = Color(t.colorValue);
                // Si solo hay una etiqueta muestra nombre completo (max 5 chars)
                // Si hay dos muestra abreviado (3 chars)
                final nombre = turnos.length == 1
                    ? t.etiquetaNombre
                        .substring(0, t.etiquetaNombre.length.clamp(0, 5))
                    : t.etiquetaNombre
                        .substring(0, t.etiquetaNombre.length.clamp(0, 3));
                return Text(
                  nombre.toLowerCase(),
                  style: TextStyle(
                    fontSize: 8,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // ── Leyenda ───────────────────────────────────────────────────────────────────

  Widget _buildLeyenda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        children: [
          _leyendaItem(_C.green, 'Trabajado'),
          ..._etiquetas.map((e) {
            final color =
                Color(int.parse('FF${e.color.replaceAll('#', '')}', radix: 16));
            return _leyendaItem(color, e.nombre);
          }),
        ],
      ),
    );
  }

  Widget _leyendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(label, style: const TextStyle(fontSize: 11, color: _C.secondary)),
      ],
    );
  }

  // ── Crear etiqueta ────────────────────────────────────────────────────────────

  void _mostrarCrearEtiqueta() {
    final ctrl = TextEditingController();
    String colorActivo = _coloresEtiqueta.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                      color: _C.muted, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Nueva etiqueta',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.primary)),
              const SizedBox(height: 14),
              // Campo nombre
              const Text('Nombre',
                  style: TextStyle(fontSize: 10, color: _C.secondary)),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _C.cardBorder),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(color: _C.primary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ej: Taxi, Plataforma, Descanso...',
                    hintStyle: TextStyle(color: _C.muted, fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Selector color
              const Text('Color',
                  style: TextStyle(fontSize: 10, color: _C.secondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _coloresEtiqueta.map((hex) {
                  final color = Color(
                      int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                  final isSelected = colorActivo == hex;
                  return GestureDetector(
                    onTap: () => setModalState(() => colorActivo = hex),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: _C.primary, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Guardar
              GestureDetector(
                onTap: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  final nueva =
                      await _bd.addEtiqueta(ctrl.text.trim(), colorActivo);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  setState(() {
                    _etiquetas.add(nueva);
                    _etiquetaActiva = nueva;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _C.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Guardar etiqueta',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F1923))),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Eliminar etiqueta ─────────────────────────────────────────────────────────

  Future<void> _confirmarEliminarEtiqueta(Etiqueta e) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _C.cardBorder),
        ),
        title: const Text('¿Eliminar etiqueta?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _C.primary, fontSize: 15, fontWeight: FontWeight.w500)),
        content: Text(
          'Se eliminará "${e.nombre}" de todos los días donde esté asignada.',
          style: const TextStyle(color: _C.secondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFF87171))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancelar', style: TextStyle(color: _C.secondary)),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await _bd.eliminarEtiqueta(e.id);
      setState(() {
        _etiquetas.removeWhere((et) => et.id == e.id);
        if (_etiquetaActiva?.id == e.id) {
          _etiquetaActiva = _etiquetas.isNotEmpty ? _etiquetas.first : null;
        }
        _turnos.removeWhere((t) => t.etiquetaId == e.id);
      });
    }
  }

  // ── Utilidades ────────────────────────────────────────────────────────────────

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

  void _entrarModoEdicion() {
    // Copia el estado actual a local
    final Map<String, List<Turno>> copia = {};
    for (final t in _turnos) {
      copia[t.fecha] = [...(copia[t.fecha] ?? []), t];
    }
    setState(() {
      _turnosLocal = copia;
      _turnosAEliminar = [];
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _turnosLocal = {};
      _turnosAEliminar = [];
      _modoEdicion = false;
    });
  }

  Future<void> _guardarEdicion() async {
    setState(() => _cargando = true);

    // Eliminar turnos marcados
    await Future.wait(
      _turnosAEliminar.map((id) => _bd.eliminarTurno(id)),
    );

    // Agregar turnos nuevos (los que no tienen id — id vacío)
    final nuevos = _turnosLocal.values
        .expand((lista) => lista)
        .where((t) => t.id.isEmpty)
        .toList();

    await Future.wait(
      nuevos.map((t) => _bd.addTurno(
            fecha: t.fecha,
            etiquetaId: t.etiquetaId,
            etiquetaNombre: t.etiquetaNombre,
            etiquetaColor: t.etiquetaColor,
          )),
    );

    setState(() {
      _modoEdicion = false;
      _turnosLocal = {};
      _turnosAEliminar = [];
    });

    await _cargarDatos();
  }

  List<Turno> _turnosDiaActual(String fechaStr) {
    if (_modoEdicion) {
      return _turnosLocal[fechaStr] ?? [];
    }
    return _turnosDia(fechaStr);
  }

  Map<String, int> get _confirmadosPorEtiqueta {
    final Map<String, int> resultado = {};
    for (final t in _turnos) {
      if (_diasTrabajados.contains(t.fecha)) {
        resultado[t.etiquetaNombre] = (resultado[t.etiquetaNombre] ?? 0) + 1;
      }
    }
    return resultado;
  }

  Map<String, int> get _planificadosPorEtiqueta {
    final Map<String, int> resultado = {};
    final hoy = DateTime.now();
    for (final t in _turnos) {
      final fecha = DateTime.parse(t.fecha);
      final esFuturo = fecha.isAfter(DateTime(hoy.year, hoy.month, hoy.day));
      if (esFuturo) {
        resultado[t.etiquetaNombre] = (resultado[t.etiquetaNombre] ?? 0) + 1;
      }
    }
    return resultado;
  }

// Para obtener el color de una etiqueta por nombre
  Color _colorEtiqueta(String nombre) {
    final etiqueta = _etiquetas.firstWhere(
      (e) => e.nombre == nombre,
      orElse: () => Etiqueta(nombre: nombre, color: '#94A3B8'),
    );
    return Color(
        int.parse('FF${etiqueta.color.replaceAll('#', '')}', radix: 16));
  }
}
