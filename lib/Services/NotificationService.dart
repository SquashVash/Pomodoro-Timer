import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _kNotificationId = 1;
const _kChannelId = 'pomodoro_timer';
const _kChannelName = 'Timer';
const _kActionPause = 'pause';
const _kActionReset = 'reset';

const _kCompleteNotificationId = 2;
const _kCompleteChannelId = 'pomodoro_complete';
const _kCompleteChannelName = 'Timer Complete';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _actions = StreamController<String>.broadcast();
  Stream<String> get onAction => _actions.stream;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (r) {
        if (r.actionId != null) _actions.add(r.actionId!);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);
  }

  Future<void> show({
    required String timerName,
    required int remainingSeconds,
    required bool isRunning,
  }) async {
    final min = remainingSeconds ~/ 60;
    final sec = remainingSeconds % 60;
    final time =
        '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: false,
      actions: [
        AndroidNotificationAction(
          _kActionPause,
          isRunning ? 'Pause' : 'Resume',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          _kActionReset,
          'Reset',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      _kNotificationId,
      timerName,
      isRunning ? time : '$time  •  Paused',
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> complete({required String timerName}) async {
    final androidDetails = AndroidNotificationDetails(
      _kCompleteChannelId,
      _kCompleteChannelName,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 400, 200, 400, 200, 600]),
      fullScreenIntent: true,
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
    );
    await _plugin.show(
      _kCompleteNotificationId,
      timerName,
      'Timer complete!',
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancel() => _plugin.cancel(_kNotificationId);
}
