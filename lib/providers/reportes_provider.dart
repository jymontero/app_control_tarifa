import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

// ── Modelos internos ──────────────────────────────────────────────────────────

class ResumenDia {
  final int dia;
  final int mes;
  final int anio;
  final int ganancia;
  final int totalBruto;
  final int deducciones;
  final int numServicios;
  final int salarioObjetivo;

  ResumenDia({
    required this.dia,
    required this.mes,
    required this.anio,
    required this.ganancia,
    required this.totalBruto,
    required this.deducciones,
    required this.numServicios,
    required this.salarioObjetivo,
  });

  DateTime get fecha => DateTime(anio, mes, dia);
  String get fechaKey => '$dia/$mes/$anio';
}

class ResumenPeriodo {
  final int totalGanancia;
  final int totalBruto;
  final int totalDeducciones;
  final int totalServicios;
  final int diasLaborados;
  final int mejorDia;
  final int peorDia;
  final double promedioPorDia;
  final int salarioObjetivo;

  ResumenPeriodo({
    required this.totalGanancia,
    required this.totalBruto,
    required this.totalDeducciones,
    required this.totalServicios,
    required this.diasLaborados,
    required this.mejorDia,
    required this.peorDia,
    required this.promedioPorDia,
    required this.salarioObjetivo,
  });

  static ResumenPeriodo vacio() => ResumenPeriodo(
        totalGanancia: 0,
        totalBruto: 0,
        totalDeducciones: 0,
        totalServicios: 0,
        diasLaborados: 0,
        mejorDia: 0,
        peorDia: 0,
        promedioPorDia: 0,
        salarioObjetivo: 0,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class ReportesProvider with ChangeNotifier {
  final FireStoreDataBase _db = FireStoreDataBase();

  bool _cargando = false;
  String _error = '';
  String _periodo = 'mensual';
  DateTime _fechaActual = DateTime.now();
  List<Ingreso> _ingresos = [];

  // ── Getters ───────────────────────────────────────────────────────────────────

  bool get cargando => _cargando;
  String get error => _error;
  String get periodo => _periodo;
  DateTime get fechaActual => _fechaActual;
  bool get hayDatos => _ingresos.isNotEmpty;

  // ── Navegación ────────────────────────────────────────────────────────────────

  DateTime get inicioSemana {
    final wd = _fechaActual.weekday;
    return DateTime(
        _fechaActual.year, _fechaActual.month, _fechaActual.day - (wd - 1));
  }

  DateTime get finSemana => inicioSemana.add(const Duration(days: 6));

  String get labelNavegacion {
    switch (_periodo) {
      case 'semanal':
        return '${_fmtDia(inicioSemana)} - ${_fmtDia(finSemana)}';
      case 'mensual':
        return '${_nombreMes(_fechaActual.month)} ${_fechaActual.year}';
      case 'anual':
        return '${_fechaActual.year}';
      default:
        return '';
    }
  }

  bool get puedeNavegaSiguiente {
    final now = DateTime.now();
    switch (_periodo) {
      case 'semanal':
        return !_mismasSemana(_fechaActual, now);
      case 'mensual':
        return _fechaActual.year < now.year ||
            (_fechaActual.year == now.year && _fechaActual.month < now.month);
      case 'anual':
        return _fechaActual.year < now.year;
      default:
        return false;
    }
  }

  // ── Acciones ──────────────────────────────────────────────────────────────────

  void setPeriodo(String periodo) {
    _periodo = periodo;
    _fechaActual = DateTime.now();
    cargarDatos();
  }

  void navegarAnterior() {
    switch (_periodo) {
      case 'semanal':
        _fechaActual = _fechaActual.subtract(const Duration(days: 7));
        break;
      case 'mensual':
        _fechaActual = DateTime(_fechaActual.year, _fechaActual.month - 1);
        break;
      case 'anual':
        _fechaActual = DateTime(_fechaActual.year - 1);
        break;
    }
    cargarDatos();
  }

  void navegarSiguiente() {
    if (!puedeNavegaSiguiente) return;
    switch (_periodo) {
      case 'semanal':
        _fechaActual = _fechaActual.add(const Duration(days: 7));
        break;
      case 'mensual':
        _fechaActual = DateTime(_fechaActual.year, _fechaActual.month + 1);
        break;
      case 'anual':
        _fechaActual = DateTime(_fechaActual.year + 1);
        break;
    }
    cargarDatos();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────────

  Future<void> cargarDatos() async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      switch (_periodo) {
        case 'semanal':
          await _cargarSemanal();
          break;
        case 'mensual':
          await _cargarMensual();
          break;
        case 'anual':
          await _cargarAnual();
          break;
      }
    } catch (e) {
      _error = e.toString();
    }

    _cargando = false;
    notifyListeners();
  }

  Future<void> _cargarMensual() async {
    _ingresos = await _db.getModeloIngresos(
      _fechaActual.month.toString(),
      _fechaActual.year.toString(),
    );
  }

  Future<void> _cargarSemanal() async {
    // Cargar mes actual
    List<Ingreso> lista = await _db.getModeloIngresos(
      _fechaActual.month.toString(),
      _fechaActual.year.toString(),
    );

    // Si la semana cruza meses cargar mes anterior también
    if (inicioSemana.month != finSemana.month) {
      final listaAnterior = await _db.getModeloIngresos(
        inicioSemana.month.toString(),
        inicioSemana.year.toString(),
      );
      lista = [...lista, ...listaAnterior];
    }

    // Filtrar por rango de semana
    _ingresos = lista.where((i) {
      final fecha =
          DateTime(int.parse(i.anio), int.parse(i.mes), int.parse(i.dia));
      return !fecha.isBefore(inicioSemana) && !fecha.isAfter(finSemana);
    }).toList();
  }

  Future<void> _cargarAnual() async {
    // 12 consultas en paralelo — una por mes
    final futures = List.generate(
      12,
      (i) => _db.getModeloIngresos(
        (i + 1).toString(),
        _fechaActual.year.toString(),
      ),
    );
    final resultados = await Future.wait(futures);
    _ingresos = resultados.expand((l) => l).toList();
  }

  // ── Datos procesados ──────────────────────────────────────────────────────────

  /// Lista de días ordenada descendente (más reciente primero)
  List<ResumenDia> get diasDetalle {
    final lista = _ingresos
        .map((i) => ResumenDia(
            dia: int.parse(i.dia),
            mes: int.parse(i.mes),
            anio: int.parse(i.anio),
            ganancia: i.monto,
            totalBruto: i.totalBruto,
            deducciones: i.deducciones,
            // Registros viejos: taxi/efectivo por defecto
            numServicios: i.numServicios,
            salarioObjetivo: i.sueldoObjetivo))
        .toList();

    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  /// Resumen agregado del período
  ResumenPeriodo get resumen {
    if (_ingresos.isEmpty) return ResumenPeriodo.vacio();

    final totalGanancia = _ingresos.fold(0, (s, i) => s + i.monto);
    final totalBruto = _ingresos.fold(0, (s, i) => s + i.totalBruto);
    final totalDeducciones = _ingresos.fold(0, (s, i) => s + i.deducciones);
    final totalServicios = _ingresos.fold(0, (s, i) => s + i.numServicios);
    final totalSalarioObjetivo =
        _ingresos.fold(0, (s, i) => s + i.sueldoObjetivo);
    final diasLaborados = _ingresos.length;
    final mejorDia =
        _ingresos.map((i) => i.monto).reduce((a, b) => a > b ? a : b);
    final peorDia =
        _ingresos.map((i) => i.monto).reduce((a, b) => a < b ? a : b);
    final promedioPorDia =
        diasLaborados > 0 ? totalGanancia / diasLaborados : 0.0;

    return ResumenPeriodo(
      totalGanancia: totalGanancia,
      totalBruto: totalBruto,
      totalDeducciones: totalDeducciones,
      totalServicios: totalServicios,
      diasLaborados: diasLaborados,
      mejorDia: mejorDia,
      peorDia: peorDia,
      promedioPorDia: promedioPorDia,
      salarioObjetivo: totalSalarioObjetivo,
    );
  }

  /// Datos para la gráfica de barras
  List<MapEntry<String, int>> get datosGrafica {
    if (_periodo == 'anual') {
      // Agrupar por mes
      final Map<int, int> porMes = {};
      for (final i in _ingresos) {
        final mes = int.parse(i.mes);
        porMes[mes] = (porMes[mes] ?? 0) + i.monto;
      }
      return List.generate(
        12,
        (i) => MapEntry(_mesCorto(i + 1), porMes[i + 1] ?? 0),
      );
    } else {
      // Agrupar por día
      final Map<String, int> porDia = {};
      for (final i in _ingresos) {
        final key = '${i.dia}/${i.mes}';
        porDia[key] = (porDia[key] ?? 0) + i.monto;
      }
      final entries = porDia.entries.toList()
        ..sort((a, b) {
          final pa = a.key.split('/');
          final pb = b.key.split('/');
          final da =
              DateTime(_fechaActual.year, int.parse(pa[1]), int.parse(pa[0]));
          final db =
              DateTime(_fechaActual.year, int.parse(pb[1]), int.parse(pb[0]));
          return da.compareTo(db);
        });
      return entries;
    }
  }

  // ── Utilidades ────────────────────────────────────────────────────────────────

  String _fmtDia(DateTime d) => '${d.day} ${_mesCorto(d.month)}';

  String _mesCorto(int mes) {
    const m = [
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
    return m[mes - 1];
  }

  String _nombreMes(int mes) {
    const m = [
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
    return m[mes - 1];
  }

  bool _mismasSemana(DateTime a, DateTime b) {
    final ia = a.subtract(Duration(days: a.weekday - 1));
    final ib = b.subtract(Duration(days: b.weekday - 1));
    return ia.year == ib.year && ia.month == ib.month && ia.day == ib.day;
  }
}
