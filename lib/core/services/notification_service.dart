import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static const int _timerId = 1;

  // Maps sound file → (channelId, rawResourceName)
  static const Map<String, (String, String)> _soundChannels = {
    'beep.wav': ('timer_beep', 'beep'),
    'bell.wav': ('timer_bell', 'bell'),
    'chime.wav': ('timer_chime', 'chime'),
    'timer_complete.wav': ('timer_complete', 'timer_complete'),
    'bell_ringing.wav': ('timer_bell_ringing', 'bell_ringing'),
  };

  static const _batteryChannel =
      MethodChannel('com.example.high_achiever/battery');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    // Set the local timezone so zonedSchedule fires at the correct local time.
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint('NotificationService: could not set local timezone: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create one Android notification channel per sound so the OS knows
    // which audio file to play even when the app is not running.
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    for (final entry in _soundChannels.entries) {
      final (channelId, rawName) = entry.value;
      await androidImpl?.createNotificationChannel(
        AndroidNotificationChannel(
          channelId,
          'Timer Alerts',
          description: 'Pomodoro timer completion sound',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(rawName),
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    // Ask the user to exempt this app from battery optimization so that
    // exact alarms are not delayed or dropped by the OS.
    if (Platform.isAndroid) {
      _requestBatteryOptimizationExemption();
    }
  }

  Future<void> _requestBatteryOptimizationExemption() async {
    try {
      await _batteryChannel
          .invokeMethod('requestBatteryOptimizationExemption');
    } catch (e) {
      debugPrint(
          'NotificationService: battery optimization request failed: $e');
    }
  }

  /// Schedule a notification to fire after [remainingSeconds].
  /// [soundFile] must match one of the keys in [_soundChannels].
  /// [isPomodoro] controls the notification text.
  Future<void> scheduleCompletion({
    required int remainingSeconds,
    required String soundFile,
    required bool isPomodoro,
  }) async {
    await cancel();

    final (channelId, rawName) =
        _soundChannels[soundFile] ?? _soundChannels['beep.wav']!;

    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: remainingSeconds));

    try {
      await _plugin.zonedSchedule(
        _timerId,
        isPomodoro ? 'Pomodoro complete! 🍅' : 'Break over! ☕',
        isPomodoro ? 'Time for a break.' : 'Time to focus!',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Timer Alerts',
            channelDescription: 'Pomodoro timer completion sound',
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound(rawName),
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: soundFile,
            presentAlert: true,
            presentSound: true,
            presentBadge: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule: $e');
    }
  }

  Future<void> cancel() async {
    try {
      await _plugin.cancel(_timerId);
    } catch (e) {
      debugPrint('NotificationService: failed to cancel: $e');
    }
  }
}