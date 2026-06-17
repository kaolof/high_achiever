import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static const int _timerId = 1;

  // Silent, low-importance channel for the ongoing live countdown notification.
  static const String _countdownChannelId = 'timer_countdown';

  // Maps sound file → (channelId, rawResourceName)
  static const Map<String, (String, String)> _soundChannels = {
    'beep.wav': ('timer_beep', 'beep'),
    'bell.wav': ('timer_bell', 'bell'),
    'chime.wav': ('timer_chime', 'chime'),
    'timer_complete.wav': ('timer_complete', 'timer_complete'),
    'bell_ringing.wav': ('timer_bell_ringing', 'bell_ringing'),

  };

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Without this tz.local defaults to UTC, which can skew scheduled times.
    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone.identifier));
    } catch (e) {
      debugPrint('NotificationService: failed to resolve local timezone: $e');
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

    // Silent channel for the live countdown (no sound, no vibration — it only
    // displays the ticking time, so it must not buzz while it's shown).
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _countdownChannelId,
        'Timer Countdown',
        description: 'Shows the running timer and remaining time',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );

    // Required on Android 13+ to show any notification at all.
    await androidImpl?.requestNotificationsPermission();
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

    final details = NotificationDetails(
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
    );

    final title = isPomodoro ? 'Pomodoro complete! 🍅' : 'Break over! ☕';
    final body = isPomodoro ? 'Time for a break.' : 'Time to focus!';

    // alarmClock (AlarmManager.setAlarmClock) fires at the exact time even under
    // Doze / battery saver — the most reliable mode for a timer. The plugin still
    // requires exact-alarm capability for this mode and throws if it's missing,
    // so if that happens we fall back to an inexact alarm: it may be delayed by
    // Doze, but a late alert beats a silent one.
    final scheduled = await _schedule(
        scheduledTime, title, body, details, AndroidScheduleMode.alarmClock);
    if (!scheduled) {
      await _schedule(scheduledTime, title, body, details,
          AndroidScheduleMode.inexactAllowWhileIdle);
    }

    // Show the live countdown now. It shares [_timerId] with the scheduled
    // completion above, so when the timer ends the completion notification
    // replaces this one automatically. Android renders the countdown natively
    // from [when], so it keeps ticking even if the app is closed.
    await _showCountdown(scheduledTime, isPomodoro);
  }

  /// Posts an ongoing notification whose chronometer counts down to
  /// [scheduledTime], shown while the timer runs (Android only).
  Future<void> _showCountdown(
      tz.TZDateTime scheduledTime, bool isPomodoro) async {
    // The chronometer (usesChronometer/chronometerCountDown) is Android-only.
    // On iOS this show() would post an immediate banner with the default sound
    // every time the timer starts, so skip it on non-Android platforms.
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _plugin.show(
        _timerId,
        isPomodoro ? 'Focusing 🍅' : 'On a break ☕',
        isPomodoro ? 'Time left in this pomodoro' : 'Time left in your break',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _countdownChannelId,
            'Timer Countdown',
            channelDescription: 'Shows the running timer and remaining time',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showWhen: true,
            when: scheduledTime.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService: failed to show countdown: $e');
    }
  }

  /// Returns true if scheduling succeeded.
  Future<bool> _schedule(
    tz.TZDateTime scheduledTime,
    String title,
    String body,
    NotificationDetails details,
    AndroidScheduleMode mode,
  ) async {
    try {
      await _plugin.zonedSchedule(
        _timerId,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('NotificationService: scheduled at $scheduledTime (mode=$mode)');
      return true;
    } catch (e) {
      debugPrint('NotificationService: schedule failed (mode=$mode): $e');
      return false;
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
