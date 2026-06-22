import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/app_settings_notifier.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/fichas/presentation/screens/fichas_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 1;

  static const _baseScreens = [HistoryScreen(), TimerScreen()];

  @override
  Widget build(BuildContext context) {
    final showTokens = context.watch<AppSettingsNotifier>().showTokensTab;

    // If tokens tab was hidden while it was active, fall back to timer
    final screens = [..._baseScreens, if (showTokens) const FichasScreen()];
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      extendBody: true,
      body: screens[safeIndex],
      bottomNavigationBar: _GlassTabBar(
        currentIndex: safeIndex,
        showTokens: showTokens,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  final int currentIndex;
  final bool showTokens;
  final ValueChanged<int> onTap;

  const _GlassTabBar({
    required this.currentIndex,
    required this.showTokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.history_rounded, 'HISTORY'),
      (Icons.timer_outlined, 'TIMER'),
      if (showTokens) (Icons.military_tech_rounded, 'TOKENS'),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.bottom,
          color: AppColors.surface.withValues(alpha: 0.80),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final (icon, label) = items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: active ? AppColors.primary : AppColors.secondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: active
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: active ? 4 : 0,
                        height: active ? 4 : 0,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
