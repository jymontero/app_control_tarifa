import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Estados del turno ─────────────────────────────────────────────────────────

enum EstadoTurno { sinIniciar, activo, pausado }

// ── Modelo de pausa ───────────────────────────────────────────────────────────

class PausaTurno {
  final String etiqueta;
  final DateTime inicio;
  DateTime? fin;

  PausaTurno({
    required this.etiqueta,
    required this.inicio,
    this.fin,
  });

  /// Si la pausa sigue activa, calcula su duración hasta este momento.
  int get duracionMinutos {
    final fechaFin = fin ?? DateTime.now();
    return fechaFin.difference(inicio).inMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'etiqueta': etiqueta,
      'inicio': inicio.millisecondsSinceEpoch,
      'fin': fin?.millisecondsSinceEpoch,
    };
  }

  factory PausaTurno.fromMap(Map<String, dynamic> map) {
    return PausaTurno(
      etiqueta: map['etiqueta'] as String,
      inicio: DateTime.fromMillisecondsSinceEpoch(
        map['inicio'] as int,
      ),
      fin: map['fin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['fin'] as int,
            )
          : null,
    );
  }
}

// ── Etiquetas de pausa fijas ──────────────────────────────────────────────────

const List<String> etiquetasPausa = [
  'Almuerzo',
  'Montallantas',
  'Descanso',
  'Otro',
];

// ── Provider ──────────────────────────────────────────────────────────────────

class TurnoProvider with ChangeNotifier, WidgetsBindingObserver {
  EstadoTurno _estado = EstadoTurno.sinIniciar;

  DateTime? _horaInicio;

  // Inicio de la pausa actualmente activa.
  DateTime? _inicioPausa;

  String? _etiquetaPausa;

  // Tiempo activo acumulado de períodos anteriores.
  int _segundosAcumulados = 0;

  // Inicio del período activo actual.
  //
  // Ejemplo:
  //
  // 09:00 inicia turno
  // 11:00 pausa
  // 11:30 reanuda
  //
  // _segundosAcumulados contiene 2 horas.
  // _inicioPeriodoActivo contiene 11:30.
  //
  // El tiempo actual será:
  //
  // 2 horas + (ahora - 11:30)
  DateTime? _inicioPeriodoActivo;

  Timer? _timer;

  // ── Vigilancia de actividad ────────────────────────────────────────────────
  DateTime? _ultimaActividad;
  Timer? _timerVigilanciaActividad;
  bool _requiereConfirmacionActividad = false;
  int _intervalosAlertados = 0;

  // Por ahora 60 minutos; el valor puede venir de configuración posteriormente.
  // static const Duration tiempoAlertaActividad = Duration(minutes: 60);
  Duration _tiempoAlertaActividad = const Duration(minutes: 60);

  Duration get tiempoAlertaActividad => _tiempoAlertaActividad;

  List<PausaTurno> _pausas = [];

  // ── Constructor ─────────────────────────────────────────────────────────────

  TurnoProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  EstadoTurno get estado => _estado;

  DateTime? get horaInicio => _horaInicio;

  String? get etiquetaPausa => _etiquetaPausa;

  List<PausaTurno> get pausas => List.unmodifiable(_pausas);

  bool get sinIniciar => _estado == EstadoTurno.sinIniciar;

  bool get activo => _estado == EstadoTurno.activo;

  bool get pausado => _estado == EstadoTurno.pausado;

  DateTime? get ultimaActividad => _ultimaActividad;

  bool get requiereConfirmacionActividad => _requiereConfirmacionActividad;

  /// Devuelve los segundos activos reales.
  ///
  /// IMPORTANTE:
  /// Este getter NO depende de que un Timer esté funcionando.
  ///
  /// Si Android suspende la aplicación durante 2 horas,
  /// DateTime.now() permitirá calcular correctamente esas 2 horas
  /// cuando la aplicación vuelva a estar disponible.
  int get segundosActivos {
    if (_estado == EstadoTurno.activo && _inicioPeriodoActivo != null) {
      final segundosTranscurridos =
          DateTime.now().difference(_inicioPeriodoActivo!).inSeconds;

      return _segundosAcumulados + segundosTranscurridos;
    }

    return _segundosAcumulados;
  }

  /// Tiempo activo formateado.
  ///
  /// Menos de una hora:
  /// 00:25
  ///
  /// Una hora o más:
  /// 1h 25m
  String get tiempoFormateado {
    final segundos = segundosActivos;

    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segundosRestantes = segundos % 60;

    if (horas > 0) {
      return '${horas}h '
          '${minutos.toString().padLeft(2, '0')}m';
    }

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundosRestantes.toString().padLeft(2, '0')}';
  }

  int get tiempoActivoMinutos {
    return segundosActivos ~/ 60;
  }

  int get tiempoPausadoMinutos {
    return _pausas.fold(
      0,
      (total, pausa) => total + pausa.duracionMinutos,
    );
  }

  // ── Inicializar ─────────────────────────────────────────────────────────────

  /// Restaura el turno guardado localmente.
  ///
  /// Si la aplicación fue cerrada mientras el turno estaba activo,
  /// NO necesitamos ejecutar ningún Timer durante el tiempo que estuvo
  /// cerrada.
  ///
  /// Simplemente restauramos _inicioPeriodoActivo y el getter
  /// segundosActivos calcula el tiempo transcurrido hasta ahora.
  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();

    final estadoGuardado = prefs.getString('turno_estado') ?? 'sinIniciar';

    if (estadoGuardado == 'sinIniciar') {
      return;
    }

    final horaInicioMs = prefs.getInt('turno_hora_inicio');

    if (horaInicioMs == null) {
      return;
    }

    _horaInicio = DateTime.fromMillisecondsSinceEpoch(
      horaInicioMs,
    );

    // ── Restaurar tiempo acumulado ────────────────────────────────────────────
    //
    // Primero intentamos utilizar el nuevo formato.
    //
    // Si existe información antigua de tu versión anterior,
    // también intentamos recuperarla.

    _segundosAcumulados = prefs.getInt('turno_segundos_acumulados') ??
        prefs.getInt('turno_segundos_activos') ??
        0;

    // ── Restaurar pausas ──────────────────────────────────────────────────────

    final pausasJson = prefs.getString('turno_pausas');

    if (pausasJson != null && pausasJson.isNotEmpty) {
      try {
        final List<dynamic> lista = jsonDecode(pausasJson);

        _pausas = lista
            .map(
              (item) => PausaTurno.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } catch (_) {
        // Si los datos están corruptos, iniciamos la lista vacía.
        _pausas = [];
      }
    }

    // ── Estado activo ─────────────────────────────────────────────────────────

    if (estadoGuardado == EstadoTurno.activo.name) {
      _estado = EstadoTurno.activo;

      final inicioPeriodoMs = prefs.getInt('turno_inicio_periodo_activo');

      if (inicioPeriodoMs != null) {
        _inicioPeriodoActivo = DateTime.fromMillisecondsSinceEpoch(
          inicioPeriodoMs,
        );
      } else {
        // Compatibilidad con la versión anterior.
        //
        // En la versión antigua se guardaba:
        // turno_ultima_actualizacion
        //
        // Ese timestamp representa aproximadamente el punto
        // desde el cual debemos continuar contando.

        final ultimaActualizacionMs =
            prefs.getInt('turno_ultima_actualizacion');

        if (ultimaActualizacionMs != null) {
          _inicioPeriodoActivo = DateTime.fromMillisecondsSinceEpoch(
            ultimaActualizacionMs,
          );
        } else {
          // Último recurso: utilizar el inicio del turno.
          _inicioPeriodoActivo = _horaInicio;
        }
      }

      _ultimaActividad = _leerFecha(prefs.getInt('turno_ultima_actividad'));
      _intervalosAlertados = prefs.getInt('turno_intervalos_alertados') ?? 0;

      // Compatibilidad: si todavía no existe la nueva marca, usamos el inicio
      // del período activo como referencia inicial.
      _ultimaActividad ??= _inicioPeriodoActivo;

      _iniciarTimer();
      _iniciarVigilanciaActividad();
    }

    // ── Estado pausado ─────────────────────────────────────────────────────────

    else if (estadoGuardado == EstadoTurno.pausado.name) {
      _estado = EstadoTurno.pausado;

      _etiquetaPausa = prefs.getString('turno_etiqueta_pausa');

      final inicioPausaMs = prefs.getInt('turno_inicio_pausa');

      if (inicioPausaMs != null) {
        _inicioPausa = DateTime.fromMillisecondsSinceEpoch(
          inicioPausaMs,
        );
      }

      // Compatibilidad con instalaciones anteriores donde
      // todavía no se habían guardado las pausas como lista.

      if (_pausas.isEmpty && _inicioPausa != null && _etiquetaPausa != null) {
        _pausas.add(
          PausaTurno(
            etiqueta: _etiquetaPausa!,
            inicio: _inicioPausa!,
          ),
        );
      }

      _inicioPeriodoActivo = null;
      _cancelarVigilanciaActividad();
      _requiereConfirmacionActividad = false;
    }

    notifyListeners();
  }
// ── Configuración de vigilancia ─────────────────────────────────────────────

  /// Actualiza el tiempo de alerta utilizado por la vigilancia de actividad.
  ///
  /// Si el turno está activo, reinicia únicamente el mecanismo de vigilancia.
  /// No modifica:
  /// - la última actividad;
  /// - el tiempo activo;
  /// - el inicio del turno;
  /// - las pausas;
  /// - el estado del turno.
  ///
  /// La nueva configuración se evalúa inmediatamente.
  void actualizarTiempoAlerta(Duration nuevaDuracion) {
    if (_tiempoAlertaActividad == nuevaDuracion) {
      return;
    }

    _tiempoAlertaActividad = nuevaDuracion;

    // El número de intervalos anteriores pertenece al intervalo anterior.
    // Por eso debemos recalcularlo utilizando la nueva configuración.
    _intervalosAlertados = 0;
    _requiereConfirmacionActividad = false;

    if (_estado == EstadoTurno.activo) {
      _cancelarVigilanciaActividad();
      _iniciarVigilanciaActividad();
    }

    notifyListeners();
  }
  // ── Iniciar turno ───────────────────────────────────────────────────────────

  Future<void> iniciarTurno() async {
    final ahora = DateTime.now();

    _horaInicio = ahora;

    _segundosAcumulados = 0;

    _inicioPeriodoActivo = ahora;
    _ultimaActividad = ahora;
    _intervalosAlertados = 0;
    _requiereConfirmacionActividad = false;

    _inicioPausa = null;

    _etiquetaPausa = null;

    _pausas = [];

    _estado = EstadoTurno.activo;

    await _guardarEstado();

    _iniciarTimer();
    _iniciarVigilanciaActividad();

    notifyListeners();
  }

  // ── Pausar turno ────────────────────────────────────────────────────────────

  Future<void> pausarTurno(String etiqueta) async {
    if (_estado != EstadoTurno.activo) {
      return;
    }

    final ahora = DateTime.now();

    // Primero acumulamos todo el tiempo activo hasta este instante.
    _acumularTiempoActivo(ahora);

    _timer?.cancel();
    _cancelarVigilanciaActividad();
    _requiereConfirmacionActividad = false;

    _inicioPausa = ahora;

    _etiquetaPausa = etiqueta;

    _estado = EstadoTurno.pausado;

    _pausas.add(
      PausaTurno(
        etiqueta: etiqueta,
        inicio: ahora,
      ),
    );

    await _guardarEstado();

    notifyListeners();
  }

  // ── Reanudar turno ──────────────────────────────────────────────────────────

  Future<void> reanudarTurno() async {
    if (_estado != EstadoTurno.pausado) {
      return;
    }

    final ahora = DateTime.now();

    // Cerrar la pausa actual.
    if (_pausas.isNotEmpty && _pausas.last.fin == null) {
      _pausas.last.fin = ahora;
    }

    _inicioPausa = null;
    _etiquetaPausa = null;

    // Comienza un nuevo período activo.
    _inicioPeriodoActivo = ahora;

    // Reanudar es una nueva actividad.
    _ultimaActividad = ahora;

    // Reiniciar el ciclo de alertas.
    _requiereConfirmacionActividad = false;
    _intervalosAlertados = 0;

    _estado = EstadoTurno.activo;

    await _guardarEstado();

    _iniciarTimer();
    _iniciarVigilanciaActividad();

    notifyListeners();
  }

  // ── Finalizar turno ─────────────────────────────────────────────────────────

  /// Finaliza el turno y devuelve sus datos.
  ///
  /// Ahora es Future porque necesitamos esperar a que SharedPreferences
  /// termine de limpiar los datos antes de finalizar completamente.
  Future<Map<String, dynamic>> finalizarTurno() async {
    final ahora = DateTime.now();

    // Si estaba trabajando, acumulamos el tiempo hasta ahora.
    if (_estado == EstadoTurno.activo) {
      _acumularTiempoActivo(ahora);
    }

    // Si estaba en pausa, cerramos la pausa.
    if (_estado == EstadoTurno.pausado) {
      if (_pausas.isNotEmpty && _pausas.last.fin == null) {
        _pausas.last.fin = ahora;
      }
    }

    _timer?.cancel();
    _cancelarVigilanciaActividad();
    _requiereConfirmacionActividad = false;

    final datos = {
      'horaInicio': _horaInicio,
      'tiempoActivoMinutos': tiempoActivoMinutos,
      'tiempoPausadoMinutos': tiempoPausadoMinutos,
      'pausas': _pausas
          .map(
            (p) => {
              'etiqueta': p.etiqueta,
              'duracionMinutos': p.duracionMinutos,
            },
          )
          .toList(),
    };

    await _resetear();

    return datos;
  }

  // ── Acumular tiempo activo ──────────────────────────────────────────────────

  void _acumularTiempoActivo(DateTime ahora) {
    if (_inicioPeriodoActivo == null) {
      return;
    }

    final segundosTranscurridos =
        ahora.difference(_inicioPeriodoActivo!).inSeconds;

    if (segundosTranscurridos > 0) {
      _segundosAcumulados += segundosTranscurridos;
    }

    _inicioPeriodoActivo = null;
  }

  // ── Actividad del turno ─────────────────────────────────────────────────────

  /// Registra actividad laboral confirmada por una acción del usuario.
  ///
  /// Un servicio creado es una actividad. También se utiliza al iniciar,
  /// reanudar y confirmar que el conductor sigue trabajando.
  Future<void> registrarActividad([DateTime? fecha]) async {
    if (_estado == EstadoTurno.pausado) {
      await reanudarTurno();
      return;
    }
    if (_estado == EstadoTurno.sinIniciar) {
      await iniciarTurno();
      return;
    }
    if (_estado != EstadoTurno.activo) return;

    _ultimaActividad = fecha ?? DateTime.now();
    _intervalosAlertados = 0;
    _requiereConfirmacionActividad = false;

    await _guardarEstado();
    _iniciarVigilanciaActividad();
    notifyListeners();
  }

  /// Debe llamarse cuando se elimina un servicio.
  ///
  /// Si todavía existen servicios, [fechaUltimoServicio] debe ser la fecha
  /// del último servicio restante. Si no quedan servicios, no modificamos la
  /// actividad del turno para no borrar una actividad válida como una
  /// reanudación o confirmación manual.
  Future<void> registrarEliminacionServicio(
      DateTime? fechaUltimoServicio) async {
    if (_estado != EstadoTurno.activo) return;

    if (fechaUltimoServicio != null) {
      _ultimaActividad = fechaUltimoServicio;
      _intervalosAlertados = 0;
      _requiereConfirmacionActividad = false;
      await _guardarEstado();
      _iniciarVigilanciaActividad();
      notifyListeners();
    }
  }

  /// El usuario confirma que continúa trabajando.
  Future<void> confirmarQueSigoTrabajando() async {
    await registrarActividad();
  }

  /// Convierte los intervalos completos de inactividad detectados en una
  /// pausa retrospectiva y deja activo el tiempo posterior a la última alerta.
  ///
  /// Ejemplo con intervalo de 60 min:
  /// 08:00 última actividad, alertas 09:00 y 10:00, respuesta NO a las 10:15.
  /// Se registra 08:00-10:00 como pausa y 10:00-10:15 permanece activo.
  Future<void> iniciarPausaPorInactividad() async {
    if (_estado != EstadoTurno.activo || _ultimaActividad == null) {
      return;
    }

    final ahora = DateTime.now();

    final minutosTranscurridos = ahora.difference(_ultimaActividad!).inMinutes;

    final cantidadIntervalos =
        minutosTranscurridos ~/ tiempoAlertaActividad.inMinutes;

    if (cantidadIntervalos <= 0) {
      return;
    }

    // Fin del último intervalo completo de inactividad.
    final finPausaRetrospectiva = _ultimaActividad!.add(
      tiempoAlertaActividad * cantidadIntervalos,
    );

    // 1. Acumular como tiempo activo hasta el final
    //    del último intervalo completo.
    if (_inicioPeriodoActivo != null) {
      _acumularTiempoActivo(finPausaRetrospectiva);
    }

    // 2. Registrar la pausa retrospectiva correspondiente
    //    únicamente a los intervalos completos.
    _pausas.add(
      PausaTurno(
        etiqueta: 'No estoy trabajando',
        inicio: _ultimaActividad!,
        fin: finPausaRetrospectiva,
      ),
    );

    // 3. El tiempo que queda después del último intervalo completo
    //    sigue siendo tiempo activo.
    //
    //    Ejemplo:
    //    08:00 última actividad
    //    10:00 fin de 2 intervalos
    //    10:15 respuesta
    //
    //    10:00 -> 10:15 sigue siendo activo.
    _inicioPeriodoActivo = finPausaRetrospectiva;
    _acumularTiempoActivo(ahora);

    // 4. AHORA comienza la pausa actual.
    _inicioPausa = ahora;
    _etiquetaPausa = 'No estoy trabajando';

    _pausas.add(
      PausaTurno(
        etiqueta: 'No estoy trabajando',
        inicio: ahora,
      ),
    );

    // 5. Cambiar realmente el estado del turno.
    _estado = EstadoTurno.pausado;

    // 6. Ya no debemos vigilar inactividad mientras estamos pausados.
    _cancelarVigilanciaActividad();

    // El timer de UI tampoco debe seguir ejecutándose.
    _timer?.cancel();

    // Ya no hay un período activo.
    _inicioPeriodoActivo = null;

    // Reiniciamos el ciclo de alertas.
    _requiereConfirmacionActividad = false;
    _intervalosAlertados = cantidadIntervalos;

    await _guardarEstado();

    // Esto hace que AppBarCustomized y los demás widgets
    // reflejen inmediatamente que el turno está pausado.
    notifyListeners();
  }

  void _iniciarVigilanciaActividad() {
    _timerVigilanciaActividad?.cancel();

    if (_estado != EstadoTurno.activo || _ultimaActividad == null) return;

    _timerVigilanciaActividad = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _comprobarActividad(),
    );

    _comprobarActividad();
  }

  void _cancelarVigilanciaActividad() {
    _timerVigilanciaActividad?.cancel();
    _timerVigilanciaActividad = null;
  }

  void _comprobarActividad() {
    if (_estado != EstadoTurno.activo || _ultimaActividad == null) return;

    final minutosTranscurridos =
        DateTime.now().difference(_ultimaActividad!).inMinutes;
    final intervalosCompletos =
        minutosTranscurridos ~/ tiempoAlertaActividad.inMinutes;

    if (intervalosCompletos > _intervalosAlertados) {
      _intervalosAlertados = intervalosCompletos;
      _requiereConfirmacionActividad = true;
      _guardarEstado();
      notifyListeners();
    }
  }

  DateTime? _leerFecha(int? milliseconds) {
    if (milliseconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  // ── Timer de actualización de UI ────────────────────────────────────────────

  /// IMPORTANTE:
  ///
  /// Este Timer NO es responsable de medir el tiempo.
  ///
  /// Solamente provoca que los widgets que utilizan Consumer<TurnoProvider>
  /// se reconstruyan cada segundo.
  ///
  /// Si Android suspende este Timer, no importa:
  /// cuando la aplicación vuelva, segundosActivos() calculará el tiempo
  /// utilizando DateTime.now().
  void _iniciarTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_estado == EstadoTurno.activo) {
          notifyListeners();
        }
      },
    );
  }

  // ── Guardar estado ──────────────────────────────────────────────────────────

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'turno_estado',
      _estado.name,
    );

    if (_horaInicio != null) {
      await prefs.setInt(
        'turno_hora_inicio',
        _horaInicio!.millisecondsSinceEpoch,
      );
    }

    await prefs.setInt(
      'turno_segundos_acumulados',
      _segundosAcumulados,
    );

    // Guardamos también el formato antiguo por compatibilidad
    // con cualquier parte del proyecto que todavía pueda utilizarlo.
    await prefs.setInt(
      'turno_segundos_activos',
      _segundosAcumulados,
    );

    if (_inicioPeriodoActivo != null) {
      await prefs.setInt(
        'turno_inicio_periodo_activo',
        _inicioPeriodoActivo!.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove(
        'turno_inicio_periodo_activo',
      );
    }

    if (_etiquetaPausa != null) {
      await prefs.setString(
        'turno_etiqueta_pausa',
        _etiquetaPausa!,
      );
    } else {
      await prefs.remove(
        'turno_etiqueta_pausa',
      );
    }

    if (_inicioPausa != null) {
      await prefs.setInt(
        'turno_inicio_pausa',
        _inicioPausa!.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove(
        'turno_inicio_pausa',
      );
    }

    if (_ultimaActividad != null) {
      await prefs.setInt(
        'turno_ultima_actividad',
        _ultimaActividad!.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove('turno_ultima_actividad');
    }

    await prefs.setInt(
      'turno_intervalos_alertados',
      _intervalosAlertados,
    );

    // Guardar todas las pausas como JSON.
    final pausasJson = jsonEncode(
      _pausas.map((p) => p.toMap()).toList(),
    );

    await prefs.setString(
      'turno_pausas',
      pausasJson,
    );
  }

  // ── Resetear ────────────────────────────────────────────────────────────────

  Future<void> _resetear() async {
    _timer?.cancel();

    _estado = EstadoTurno.sinIniciar;

    _horaInicio = null;

    _inicioPausa = null;

    _etiquetaPausa = null;

    _segundosAcumulados = 0;

    _inicioPeriodoActivo = null;
    _ultimaActividad = null;
    _requiereConfirmacionActividad = false;
    _intervalosAlertados = 0;

    _pausas = [];

    final prefs = await SharedPreferences.getInstance();

    // Estado actual.
    await prefs.remove('turno_estado');
    await prefs.remove('turno_hora_inicio');
    await prefs.remove('turno_segundos_acumulados');
    await prefs.remove('turno_inicio_periodo_activo');
    await prefs.remove('turno_pausas');

    // Datos de pausas.
    await prefs.remove('turno_etiqueta_pausa');
    await prefs.remove('turno_inicio_pausa');

    // Datos utilizados por la versión anterior.
    await prefs.remove('turno_segundos_activos');
    await prefs.remove('turno_ultima_actualizacion');
    await prefs.remove('turno_ultima_actividad');
    await prefs.remove('turno_intervalos_alertados');

    notifyListeners();
  }

  // ── Ciclo de vida de la aplicación ──────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      // No necesitamos calcular manualmente los segundos.
      //
      // segundosActivos ya utiliza DateTime.now().
      //
      // Solo notificamos para que el AppBar y demás widgets
      // actualicen inmediatamente el valor mostrado.
      if (_estado == EstadoTurno.activo) {
        _comprobarActividad();
        _iniciarVigilanciaActividad();
        notifyListeners();
      }
    }
  }

  // ── Dispose ─────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _timer?.cancel();
    _cancelarVigilanciaActividad();

    super.dispose();
  }
}
