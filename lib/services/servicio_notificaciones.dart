import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ServicioNotificaciones {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _idAlertaPrueba = 1001;

  static const String _channelId = 'turno_actividad';
  static const String _channelName = 'Actividad del turno';
  static const String _channelDescription =
      'Notificaciones relacionadas con la actividad del turno';

  Future<void> inicializar() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initializationSettings,
    );

    const canal = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);

    await _solicitarPermisoNotificaciones();
  }

  Future<void> _solicitarPermisoNotificaciones() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> programarNotificacionPrueba() async {
    final ahora = tz.TZDateTime.now(tz.local);

    final fechaNotificacion = ahora.add(
      const Duration(seconds: 30),
    );

    await _plugin.zonedSchedule(
      _idAlertaPrueba,
      'Control de turno',
      'Esta es una notificación de prueba.',
      fechaNotificacion,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelarNotificacionPrueba() async {
    await _plugin.cancel(_idAlertaPrueba);
  }
}
