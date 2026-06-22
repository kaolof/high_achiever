import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_notifier.dart';
import '../../../../core/services/notification_service.dart';

/// First-run intro. A horizontal [PageView] of informative slides followed by a
/// notification-priming step. Completion is persisted via
/// [AppSettingsNotifier.onboardingCompleted] so it shows only once.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = <_SlideData>[
    _SlideData(
      icon: Icons.self_improvement_rounded,
      title: 'Welcome to High Achiever',
      body: 'Focus deeply, one session at a time. Let’s show you around.',
    ),
    _SlideData(
      icon: Icons.timer_outlined,
      title: 'Focus with the timer',
      body:
          'Start a pomodoro to focus, then take a break. The timer keeps running '
          'even when the app is closed.',
    ),
    _SlideData(
      icon: Icons.screen_rotation_rounded,
      title: 'Fullscreen & Flip Mode',
      body:
          'Tap the fullscreen icon for a distraction-free timer. With Flip Mode '
          'on, just rotate your phone 180° to start the next session — no '
          'tapping needed. We’ll explain it again when you get there.',
    ),
    _SlideData(
      icon: Icons.history_rounded,
      title: 'Track your history',
      body:
          'Every completed session is saved so you can see how consistent '
          'you’ve been over time.',
    ),
    _SlideData(
      icon: Icons.military_tech_rounded,
      title: 'Earn tokens',
      body:
          'Turn your focus into rewards. Enable the Tokens tab anytime from '
          'settings.',
    ),
  ];

  bool get _isLastSlide => _page == _slides.length;
  int get _pageCount => _slides.length + 1; // +1 for the notifications step

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    context.read<AppSettingsNotifier>().onboardingCompleted = true;
  }

  Future<void> _enableNotifications() async {
    final granted = await context
        .read<NotificationService>()
        .requestPermissions();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podés activarlas luego desde Ajustes.')),
      );
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip — hidden on the final (notifications) step.
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: _isLastSlide ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _isLastSlide ? null : _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final slide in _slides) _Slide(data: slide),
                  _NotificationsStep(onEnable: _enableNotifications),
                ],
              ),
            ),
            _Dots(count: _pageCount, active: _page),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _isLastSlide
                  ? TextButton(onPressed: _finish, child: const Text('Not now'))
                  : _PrimaryButton(label: 'Next', onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String body;
  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _Slide extends StatelessWidget {
  final _SlideData data;
  const _Slide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Icon(data.icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  final VoidCallback onEnable;
  const _NotificationsStep({required this.onEnable});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Stay on track',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Allow notifications so we can alert you the moment a focus session '
            'or break ends — even when the app is closed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          _PrimaryButton(label: 'Enable notifications', onPressed: onEnable),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
