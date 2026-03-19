import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/audio_service.dart';

enum TimerPhase { pomodoro, breakTime }

class TimerNotifier extends ChangeNotifier {
  static const int defaultPomodoroDuration = 25 * 60;
  static const int defaultBreakDuration = 5 * 60;
  static const String defaultTaskName = 'Design Sprint';

  static const String _keyCompletedToday = 'completed_today';
  static const String _keyLastDate = 'last_date';
  static const String _keyDailyGoal = 'daily_goal';
  static const String _keyTimerStartEpoch = 'timer_start_epoch';
  static const String _keyRemainingAtStart = 'remaining_at_start';
  static const String _keyPomodoroDuration = 'pomodoro_duration';
  static const String _keyBreakDuration = 'break_duration';
  static const String _keyIsBreak = 'is_break';
  static const String _keyPomodoroSound = 'pomodoro_sound';
  static const String _keyBreakSound = 'break_sound';
  static const String defaultSound = 'beep.wav';

  int _pomodoroDuration = defaultPomodoroDuration;
  int _breakDuration = defaultBreakDuration;
  int _remainingSeconds = defaultPomodoroDuration;
  TimerPhase _phase = TimerPhase.pomodoro;
  bool _isRunning = false;
  Timer? _timer;
  int _dailyGoal = 8;
  int _completedToday = 0;
  bool _justCompleted = false;
  String _pomodoroSound = defaultSound;
  String _breakSound = defaultSound;

  int get minutes => _remainingSeconds ~/ 60;
  int get seconds => _remainingSeconds % 60;
  bool get isRunning => _isRunning;
  TimerPhase get phase => _phase;
  bool get isBreak => _phase == TimerPhase.breakTime;
  int get dailyGoal => _dailyGoal;
  int get completedToday => _completedToday;
  int get pomodoroDuration => _pomodoroDuration;
  int get breakDuration => _breakDuration;
  String get pomodoroSound => _pomodoroSound;
  String get breakSound => _breakSound;

  /// true for 1 second when a phase ends (to animate the UI)
  bool get justCompleted => _justCompleted;

  final SharedPreferences _prefs;
  final AudioService _audio;

  TimerNotifier(this._prefs, this._audio) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    try {
      _dailyGoal = _prefs.getInt(_keyDailyGoal) ?? 8;
      _pomodoroDuration =
          _prefs.getInt(_keyPomodoroDuration) ?? defaultPomodoroDuration;
      _breakDuration =
          _prefs.getInt(_keyBreakDuration) ?? defaultBreakDuration;
      _phase = (_prefs.getBool(_keyIsBreak) ?? false)
          ? TimerPhase.breakTime
          : TimerPhase.pomodoro;
      _remainingSeconds =
          _phase == TimerPhase.pomodoro ? _pomodoroDuration : _breakDuration;
      _pomodoroSound = _prefs.getString(_keyPomodoroSound) ?? defaultSound;
      _breakSound = _prefs.getString(_keyBreakSound) ?? defaultSound;

      final today = _todayString();
      final savedDate = _prefs.getString(_keyLastDate) ?? '';
      if (savedDate == today) {
        _completedToday = _prefs.getInt(_keyCompletedToday) ?? 0;
      } else {
        _completedToday = 0;
        _prefs.setString(_keyLastDate, today);
        _prefs.setInt(_keyCompletedToday, 0);
      }

      _reconcileFromPrefs();
    } catch (e) {
      debugPrint('TimerNotifier: failed to load state: $e');
    }
  }

  /// Recalculates remaining time based on how much time passed in the background.
  void reconcileAfterBackground() {
    if (!_isRunning) return;
    _reconcileFromPrefs();
  }

  void _reconcileFromPrefs() {
    final startEpoch = _prefs.getInt(_keyTimerStartEpoch);
    if (startEpoch == null) return;

    final remainingAtStart =
        _prefs.getInt(_keyRemainingAtStart) ?? _currentPhaseDuration;
    final elapsedSeconds =
        (DateTime.now().millisecondsSinceEpoch - startEpoch) ~/ 1000;
    final newRemaining = remainingAtStart - elapsedSeconds;

    if (newRemaining <= 0) {
      _prefs.remove(_keyTimerStartEpoch);
      _timer?.cancel();
      _isRunning = false;
      _audio.play(_phase == TimerPhase.pomodoro ? _pomodoroSound : _breakSound);
      if (_phase == TimerPhase.pomodoro) {
        _completedToday++;
        _saveToPrefs();
        _justCompleted = true;
        _switchToBreak();
        notifyListeners();
        Timer(const Duration(seconds: 1), () {
          _justCompleted = false;
          notifyListeners();
        });
      } else {
        _justCompleted = true;
        _switchToPomodoro();
        notifyListeners();
        Timer(const Duration(seconds: 1), () {
          _justCompleted = false;
          notifyListeners();
        });
      }
    } else {
      _remainingSeconds = newRemaining;
      _prefs.setInt(_keyTimerStartEpoch, DateTime.now().millisecondsSinceEpoch);
      _prefs.setInt(_keyRemainingAtStart, _remainingSeconds);
      if (!_isRunning) {
        _isRunning = true;
        _startTicker();
      }
      notifyListeners();
    }
  }

  int get _currentPhaseDuration =>
      _phase == TimerPhase.pomodoro ? _pomodoroDuration : _breakDuration;

  void _switchToBreak() {
    _phase = TimerPhase.breakTime;
    _remainingSeconds = _breakDuration;
    _prefs.setBool(_keyIsBreak, true);
  }

  void _switchToPomodoro() {
    _phase = TimerPhase.pomodoro;
    _remainingSeconds = _pomodoroDuration;
    _prefs.setBool(_keyIsBreak, false);
  }

  Future<void> _saveToPrefs() async {
    try {
      await _prefs.setInt(_keyCompletedToday, _completedToday);
      await _prefs.setString(_keyLastDate, _todayString());
    } catch (e) {
      debugPrint('TimerNotifier: failed to persist state: $e');
    }
  }

  Future<void> setPomodoroSound(String soundFile) async {
    _pomodoroSound = soundFile;
    notifyListeners();
    await _prefs.setString(_keyPomodoroSound, soundFile);
  }

  Future<void> setBreakSound(String soundFile) async {
    _breakSound = soundFile;
    notifyListeners();
    await _prefs.setString(_keyBreakSound, soundFile);
  }

  void previewSound(String soundFile) => _audio.play(soundFile);

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    notifyListeners();
    await _prefs.setInt(_keyDailyGoal, goal);
  }

  Future<void> setPomodoroDuration(int totalSeconds) async {
    _pomodoroDuration = totalSeconds;
    await _prefs.setInt(_keyPomodoroDuration, totalSeconds);
    if (!_isRunning && _phase == TimerPhase.pomodoro) {
      _remainingSeconds = totalSeconds;
    }
    notifyListeners();
  }

  Future<void> setBreakDuration(int totalSeconds) async {
    _breakDuration = totalSeconds;
    await _prefs.setInt(_keyBreakDuration, totalSeconds);
    if (!_isRunning && _phase == TimerPhase.breakTime) {
      _remainingSeconds = totalSeconds;
    }
    notifyListeners();
  }

  void toggle() {
    _isRunning ? _pause() : _start();
  }

  void _start() {
    _isRunning = true;
    _prefs.setInt(_keyTimerStartEpoch, DateTime.now().millisecondsSinceEpoch);
    _prefs.setInt(_keyRemainingAtStart, _remainingSeconds);
    notifyListeners();
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds == 0) {
        _onPhaseComplete();
        return;
      }
      _remainingSeconds--;
      notifyListeners();
    });
  }

  Future<void> _onPhaseComplete() async {
    _timer?.cancel();
    _isRunning = false;
    _prefs.remove(_keyTimerStartEpoch);
    _audio.play(_phase == TimerPhase.pomodoro ? _pomodoroSound : _breakSound);

    if (_phase == TimerPhase.pomodoro) {
      _completedToday++;
      await _saveToPrefs();
      _justCompleted = true;
      _switchToBreak();
      notifyListeners();
      Timer(const Duration(seconds: 1), () {
        _justCompleted = false;
        notifyListeners();
      });
    } else {
      _justCompleted = true;
      _switchToPomodoro();
      notifyListeners();
      Timer(const Duration(seconds: 1), () {
        _justCompleted = false;
        notifyListeners();
      });
    }
  }

  void _pause() {
    _timer?.cancel();
    _isRunning = false;
    _prefs.remove(_keyTimerStartEpoch);
    notifyListeners();
  }

  /// Skips the current break and returns to a ready pomodoro.
  void skipBreak() {
    if (_phase != TimerPhase.breakTime) return;
    _timer?.cancel();
    _isRunning = false;
    _switchToPomodoro();
    _prefs.remove(_keyTimerStartEpoch);
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _switchToPomodoro();
    _prefs.remove(_keyTimerStartEpoch);
    _prefs.setBool(_keyIsBreak, false);
    notifyListeners();
  }

  Future<void> resetSession() async {
    _timer?.cancel();
    _isRunning = false;
    _completedToday = 0;
    _switchToPomodoro();
    _prefs.remove(_keyTimerStartEpoch);
    _prefs.setBool(_keyIsBreak, false);
    await _saveToPrefs();
    notifyListeners();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
