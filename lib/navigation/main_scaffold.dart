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
  // Index 1 is always the center tab you land on: the Token System when it's
  // active, otherwise the Timer.
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final showTokens = context.watch<AppSettingsNotifier>().showTokensTab;

    // When the Token System is active it takes the CENTER slot and becomes the
    // default landing tab; the Timer moves to the right. When it's off, the bar
    // is just History + Timer, with the Timer as the center/default tab.
    final tabs = <(Widget, IconData, String)>[
      (const HistoryScreen(), Icons.history_rounded, 'HISTORY'),
      if (showTokens)
        (const FichasScreen(), Icons.military_tech_rounded, 'TOKENS'),
      (const TimerScreen(), Icons.timer_outlined, 'TIMER'),
    ];
    // Clamp so toggling the tab off while it was selected falls back safely.
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      extendBody: true,
      body: tabs[safeIndex].$1,
      bottomNavigationBar: _GlassTabBar(
        currentIndex: safeIndex,
        items: [for (final t in tabs) (t.$2, t.$3)],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  final int currentIndex;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;

  const _GlassTabBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.bottom,
          color: AppColors.surface.withValues(alpha: 0.80),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
