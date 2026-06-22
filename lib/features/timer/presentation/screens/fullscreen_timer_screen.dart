import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_notifier.dart';
import '../../domain/timer_notifier.dart';

class FullscreenTimerScreen extends StatefulWidget {
  const FullscreenTimerScreen({super.key});

  static const _bgColor = Color(0xFF1A1F1C);

  static Future<void> show(BuildContext context) async {
    // Capture context references before any async gap.
    final overlayState = Overlay.of(context);
    final navigator = Navigator.of(context);

    // Detect the current device orientation before rotating.
    DeviceOrientation initialOrientation;
    try {
      final e = await accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).first.timeout(const Duration(milliseconds: 300));
      // x > 0 → right side down → landscapeLeft
      // x < 0 → left side down → landscapeRight
      initialOrientation = e.x > 0
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.landscapeRight;
    } catch (_) {
      initialOrientation = DeviceOrientation.landscapeLeft;
    }

    // Cover the screen immediately so the rotation is hidden behind a solid color.
    final entry = OverlayEntry(
      builder: (_) =>
          const ColoredBox(color: _bgColor, child: SizedBox.expand()),
    );
    overlayState.insert(entry);

    await SystemChrome.setPreferredOrientations([initialOrientation]);
    // Wait for the physical rotation to settle.
    await Future.delayed(const Duration(milliseconds: 380));

    if (!context.mounted) {
      entry.remove();
      return;
    }

    // Remove overlay after the route has had two frames to paint itself.
    bool entryRemoved = false;
    void removeEntry() {
      if (!entryRemoved) {
        entryRemoved = true;
        entry.remove();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => removeEntry());
    });

    try {
      await navigator.push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const FullscreenTimerScreen(),
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
    } finally {
      removeEntry(); // safety – remove if still present after pop

      // Cover again while rotating back to portrait.
      if (context.mounted) {
        final exitEntry = OverlayEntry(
          builder: (_) =>
              const ColoredBox(color: Colors.black, child: SizedBox.expand()),
        );
        Overlay.of(context).insert(exitEntry);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        await Future.delayed(const Duration(milliseconds: 380));
        exitEntry.remove();
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    }
  }

  @override
  State<FullscreenTimerScreen> createState() => _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends State<FullscreenTimerScreen>
    with WidgetsBindingObserver {
  late final TimerNotifier _timer;
  late final AppSettingsNotifier _settings;
  TimerPhase? _prevPhase;

  bool _awaitingFlip = false;
  bool _showIntro = false;
  double? _initialAccelZ;
  double _maxAccelX = 0;
  double _minAccelX = 0;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void initState() {
    super.initState();
    _timer = context.read<TimerNotifier>();
    _settings = context.read<AppSettingsNotifier>();
    _prevPhase = _timer.phase;
    _showIntro = !_settings.fullscreenIntroSeen;
    _timer.addListener(_onTimerChanged);
    WidgetsBinding.instance.addObserver(this);
    _sampleInitialAccel();
    WakelockPlus.enable();
  }

  void _dismissIntro() {
    _settings.fullscreenIntroSeen = true;
    setState(() => _showIntro = false);
  }

  void _sampleInitialAccel() {
    accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).first.then((e) {
      if (mounted) {
        _initialAccelZ = e.z;
      }
    });
  }

  void _onTimerChanged() {
    if (!mounted) return;
    if (_timer.phase != _prevPhase) {
      final flipEnabled = _settings.flipMode;
      setState(() {
        _prevPhase = _timer.phase;
        _awaitingFlip = flipEnabled;
      });
      if (flipEnabled) _beginFlipListening();
    }
  }

  void _beginFlipListening() {
    // Snapshot the current position to know the "start" side.
    accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).first.then((e) {
      if (!mounted) return;
      _initialAccelZ = e.z;
      _maxAccelX = e.x;
      _minAccelX = e.x;
      _accelSub?.cancel();
      _accelSub =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.normalInterval,
          ).listen((e) {
            _maxAccelX = max(_maxAccelX, e.x);
            _minAccelX = min(_minAccelX, e.x);
            if (_isFlipped180(e)) _onFlipConfirmed(e.x);
          });
    });
  }

  /// Detects a 180° flip via accelerometer.
  ///
  /// X-axis roll: tracks max and min X seen since listening started.
  /// If X has crossed both +6 and -6, the phone has rotated 180° regardless
  /// of starting position (flat, landscape-left, landscape-right, etc.).
  ///
  /// Z-axis flip: face-up (z ≈ +9.8) → face-down (z ≈ -9.8).
  bool _isFlipped180(AccelerometerEvent e) {
    final landscapeFlip = _maxAccelX > 6 && _minAccelX < -6;
    final initZ = _initialAccelZ;
    final faceFlip =
        initZ != null && ((initZ > 4 && e.z < -4) || (initZ < -4 && e.z > 4));
    return landscapeFlip || faceFlip;
  }

  void _onFlipConfirmed(double finalX) {
    _accelSub?.cancel();
    _accelSub = null;
    if (!mounted) return;

    // Force the orientation that matches the physical position of the phone.
    // x > 0 → right side of device points down → landscapeLeft
    // x < 0 → left side of device points down → landscapeRight
    // If x is near 0 (phone flat), keep current orientation.
    if (finalX.abs() > 4) {
      final orientation = finalX > 0
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.landscapeRight;
      SystemChrome.setPreferredOrientations([orientation]);
    }

    setState(() => _awaitingFlip = false);
    _timer.toggle();

    // Keep the new orientation locked so the OS auto-rotate setting doesn't
    // interfere and flip it back. Just sample the new accelerometer baseline
    // after the physical rotation settles.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _sampleInitialAccel();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingFlip) {
      _beginFlipListening();
    }
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerChanged);
    WidgetsBinding.instance.removeObserver(this);
    _accelSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _setFlipMode(bool enabled) {
    _settings.flipMode = enabled;
    if (!enabled) {
      _accelSub?.cancel();
      _accelSub = null;
      if (_awaitingFlip) setState(() => _awaitingFlip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNotifier>();
    final flipEnabled = context.watch<AppSettingsNotifier>().flipMode;
    final timeText =
        '${timer.minutes.toString().padLeft(2, '0')}:${timer.seconds.toString().padLeft(2, '0')}';
    final phaseLabel = timer.isBreak ? 'BREAK' : 'FOCUS';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F1C),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 20,
              child: _FlipModeToggle(
                enabled: flipEnabled,
                onChanged: _setFlipMode,
              ),
            ),
            Positioned(
              top: 16,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.fullscreen_exit_rounded,
                  color: Color(0xFF4A5450),
                  size: 30,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phaseLabel,
                    style: const TextStyle(
                      color: Color(0xFF4A5450),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 120,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -4,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_awaitingFlip && flipEnabled)
                    _FlipPrompt(isBreak: timer.isBreak)
                  else
                    _PlayPauseButton(
                      isRunning: timer.isRunning,
                      onTap: timer.toggle,
                    ),
                  if (timer.isBreak) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: timer.skipBreak,
                      child: const Text(
                        'Skip Break',
                        style: TextStyle(
                          color: Color(0xFF4A5450),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_showIntro)
              _FullscreenIntro(
                flipEnabled: flipEnabled,
                onDismiss: _dismissIntro,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// First-run intro overlay — explains fullscreen + flip mode once.
// ---------------------------------------------------------------------------

class _FullscreenIntro extends StatelessWidget {
  final bool flipEnabled;
  final VoidCallback onDismiss;

  const _FullscreenIntro({required this.flipEnabled, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      // Swallow taps on the backdrop so they don't reach the timer behind, but
      // dismiss only via the explicit "Got it" button to avoid accidental taps.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.82),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fit_screen_rounded,
                      color: AppColors.accent,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fullscreen focus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _IntroRow(
                      icon: Icons.do_not_disturb_on_total_silence_rounded,
                      text:
                          'A distraction-free timer. The screen stays awake so you '
                          'can keep an eye on it.',
                    ),
                    const SizedBox(height: 14),
                    _IntroRow(
                      icon: Icons.screen_rotation_rounded,
                      text: flipEnabled
                          ? 'Flip Mode is on: when a session ends, rotate your '
                                'phone 180° to start the next one — no tapping.'
                          : 'Turn on Flip Mode (top-left) to advance hands-free: '
                                'rotate your phone 180° to start the next session.',
                    ),
                    const SizedBox(height: 14),
                    const _IntroRow(
                      icon: Icons.fullscreen_exit_rounded,
                      text: 'Tap the exit icon (top-right) to return anytime.',
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Text(
                          'Got it',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IntroRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFC7CFCB),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Flip mode toggle (in-fullscreen shortcut to enable/disable flip mode)
// ---------------------------------------------------------------------------

class _FlipModeToggle extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FlipModeToggle({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.accent : const Color(0xFF4A5450);
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accent.withValues(alpha: 0.12)
              : const Color(0xFF4A5450).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled
                  ? Icons.screen_rotation_rounded
                  : Icons.screen_lock_rotation_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              enabled ? 'Flip On' : 'Flip Off',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flip prompt widget
// ---------------------------------------------------------------------------

class _FlipPrompt extends StatefulWidget {
  final bool isBreak;
  const _FlipPrompt({required this.isBreak});

  @override
  State<_FlipPrompt> createState() => _FlipPromptState();
}

class _FlipPromptState extends State<_FlipPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isBreak ? 'start break' : 'next pomodoro';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.rotate(
            angle: _ctrl.value * pi,
            child: const Icon(
              Icons.screen_rotation_rounded,
              color: AppColors.accent,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Rotate 180° to $label',
          style: const TextStyle(
            color: Color(0xFF4A5450),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Play / Pause button
// ---------------------------------------------------------------------------

class _PlayPauseButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              color: AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isRunning ? 'Pause' : 'Start',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
