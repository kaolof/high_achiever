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

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

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

    final androidImpl = _android;

    // Create one Android notification channel per sound so the OS knows
    // which audio file to play even when the app is not running.
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

    // The backup completion alarm uses alarmClock mode, which requires
    // exact-alarm capability; without it the plugin throws and we silently
    // degrade to a Doze-deferred inexact alarm that never fires on time in the
    // background. Request it up front so the killed-process fallback stays
    // reliable. On Android 13+ with USE_EXACT_ALARM this is already granted and
    // no prompt appears.
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;
    if (canExact == false) {
      await androidImpl?.requestExactAlarmsPermission();
    }
  }

  /// Builds the completion (sound) notification details for [soundFile].
  NotificationDetails _completionDetails(String soundFile) {
    final (channelId, rawName) =
        _soundChannels[soundFile] ?? _soundChannels['beep.wav']!;
    return NotificationDetails(
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
  }

  /// Schedule the completion alert to fire after [remainingSeconds] and start
  /// the live countdown as a foreground service.
  /// [soundFile] must match one of the keys in [_soundChannels].
  /// [isPomodoro] controls the notification text.
  Future<void> scheduleCompletion({
    required int remainingSeconds,
    required String soundFile,
    required bool isPomodoro,
  }) async {
    await cancel();

    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: remainingSeconds));
    final details = _completionDetails(soundFile);
    final title = isPomodoro ? 'Pomodoro complete! 🍅' : 'Break over! ☕';
    final body = isPomodoro ? 'Time for a break.' : 'Time to focus!';

    // Backup alarm: fires the completion sound even if the OS kills our process
    // (foreground service gone). alarmClock (AlarmManager.setAlarmClock) is
    // exact and fires even under Doze; the plugin requires exact-alarm
    // capability for it and throws otherwise, so we fall back to an inexact
    // alarm — a late alert beats a silent one.
    final scheduled = await _schedule(
        scheduledTime, title, body, details, AndroidScheduleMode.alarmClock);
    if (!scheduled) {
      await _schedule(scheduledTime, title, body, details,
          AndroidScheduleMode.inexactAllowWhileIdle);
    }

    // Primary path: run the live countdown as a foreground service. This keeps
    // our process alive so the Dart timer keeps ticking while the app is in the
    // background and can fire the completion sound itself (see
    // TimerNotifier._onPhaseComplete), instead of relying on the OEM to honor
    // the alarm. It shares [_timerId] with the scheduled completion so the alert
    // replaces the countdown when it ends.
    await _startCountdownService(scheduledTime, isPomodoro);
  }

  /// Posts the completion alert immediately. Used when the timer reaches zero
  /// while the app is backgrounded but our process is still alive (kept alive by
  /// the foreground service). Cancels the countdown service and the pending
  /// backup alarm first so nothing double-fires.
  Future<void> showCompletionNow({
    required String soundFile,
    required bool isPomodoro,
  }) async {
    await cancel();
    final title = isPomodoro ? 'Pomodoro complete! 🍅' : 'Break over! ☕';
    final body = isPomodoro ? 'Time for a break.' : 'Time to focus!';
    try {
      await _plugin.show(_timerId, title, body, _completionDetails(soundFile));
    } catch (e) {
      debugPrint('NotificationService: failed to show completion: $e');
    }
  }

  /// Runs the live countdown notification as a foreground service so the app
  /// process (and its Dart timer) survives being backgrounded. Android renders
  /// the countdown natively from [when], so it keeps ticking even off-screen.
  /// Falls back to a plain ongoing notification if the service can't start.
  Future<void> _startCountdownService(
      tz.TZDateTime scheduledTime, bool isPomodoro) async {
    final countdown = AndroidNotificationDetails(
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
    );
    try {
      await _android?.startForegroundService(
        _timerId,
        isPomodoro ? 'Focusing 🍅' : 'On a break ☕',
        isPomodoro ? 'Time left in this pomodoro' : 'Time left in your break',
        notificationDetails: countdown,
        foregroundServiceTypes: const {
          AndroidServiceForegroundType.foregroundServiceTypeSpecialUse,
        },
      );
    } catch (e) {
      // Older OS versions / restricted configs may reject the service start;
      // degrade to a plain ongoing notification so the countdown still shows and
      // the backup alarm remains the alert path.
      debugPrint('NotificationService: foreground service failed, falling back '
          'to a plain notification: $e');
      try {
        await _plugin.show(
          _timerId,
          isPomodoro ? 'Focusing 🍅' : 'On a break ☕',
          isPomodoro ? 'Time left in this pomodoro' : 'Time left in your break',
          NotificationDetails(android: countdown),
        );
      } catch (e) {
        debugPrint('NotificationService: failed to show countdown: $e');
      }
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

  /// Stops the countdown foreground service and cancels the pending backup
  /// alarm / any shown notification (all share [_timerId]).
  Future<void> cancel() async {
    try {
      await _android?.stopForegroundService();
    } catch (e) {
      debugPrint('NotificationService: failed to stop foreground service: $e');
    }
    try {
      await _plugin.cancel(_timerId);
    } catch (e) {
      debugPrint('NotificationService: failed to cancel: $e');
    }
  }
}
