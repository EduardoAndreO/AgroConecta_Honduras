import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'agroconecta_orders',
      'Pedidos y pagos',
      description: 'Alertas de pedidos, pagos y actualizaciones de AgroConecta',
      importance: Importance.max,
      playSound: true,
    ));
  }

  Future<void> show({required String title, required String body}) async {
    const details = AndroidNotificationDetails(
      'agroconecta_orders',
      'Pedidos y pagos',
      channelDescription:
          'Alertas de pedidos, pagos y actualizaciones de AgroConecta',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title, body, const NotificationDetails(android: details));
  }
}
