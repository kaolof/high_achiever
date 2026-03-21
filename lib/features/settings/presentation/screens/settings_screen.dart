import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../timer/domain/timer_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        titleSpacing: 24,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          const _SectionLabel('Timer'),
          const SizedBox(height: 12),
          const _DurationTile(
            label: 'Pomodoro',
            icon: Icons.timer_outlined,
            isPomodoro: true,
          ),
          const SizedBox(height: 12),
          const _DurationTile(
            label: 'Break',
            icon: Icons.coffee_outlined,
            isPomodoro: false,
          ),
          const SizedBox(height: 32),
          const _SectionLabel('Sounds'),
          const SizedBox(height: 12),
          const _SoundTile(
            label: 'Pomodoro sound',
            icon: Icons.timer_outlined,
            isPomodoro: true,
          ),
          const SizedBox(height: 12),
          const _SoundTile(
            label: 'Break sound',
            icon: Icons.coffee_outlined,
            isPomodoro: false,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPomodoro;

  const _DurationTile({
    required this.label,
    required this.icon,
    required this.isPomodoro,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNotifier>();
    final totalSeconds =
        isPomodoro ? timer.pomodoroDuration : timer.breakDuration;
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSecondaryFixed.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showEditSheet(context, mins, secs),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, int currentMins, int currentSecs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DurationEditSheet(
        label: label,
        initialMins: currentMins,
        initialSecs: currentSecs,
        isPomodoro: isPomodoro,
      ),
    );
  }
}

class _DurationEditSheet extends StatefulWidget {
  final String label;
  final int initialMins;
  final int initialSecs;
  final bool isPomodoro;

  const _DurationEditSheet({
    required this.label,
    required this.initialMins,
    required this.initialSecs,
    required this.isPomodoro,
  });

  @override
  State<_DurationEditSheet> createState() => _DurationEditSheetState();
}

class _DurationEditSheetState extends State<_DurationEditSheet> {
  late final TextEditingController _minsCtrl;
  late final TextEditingController _secsCtrl;

  @override
  void initState() {
    super.initState();
    _minsCtrl = TextEditingController(
      text: widget.initialMins.toString().padLeft(2, '0'),
    );
    _secsCtrl = TextEditingController(
      text: widget.initialSecs.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _minsCtrl.dispose();
    _secsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final mins = int.tryParse(_minsCtrl.text) ?? 0;
    final secs = int.tryParse(_secsCtrl.text) ?? 0;
    final total = mins * 60 + secs;

    if (total <= 0) return; // do not allow 0 seconds

    final timer = context.read<TimerNotifier>();
    if (widget.isPomodoro) {
      timer.setPomodoroDuration(total);
    } else {
      timer.setBreakDuration(total);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.label} duration',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    controller: _minsCtrl,
                    label: 'Minutes',
                    max: 99,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: _TimeField(
                    controller: _secsCtrl,
                    label: 'Seconds',
                    max: 59,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int max;

  const _TimeField({
    required this.controller,
    required this.label,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _MaxValueFormatter(max),
          ],
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onTap: () => controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          ),
        ),
      ],
    );
  }
}

class _SoundTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPomodoro;

  const _SoundTile({
    required this.label,
    required this.icon,
    required this.isPomodoro,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerNotifier>();
    final currentFile =
        isPomodoro ? timer.pomodoroSound : timer.breakSound;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSecondaryFixed.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showPickerSheet(context, currentFile),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AudioService.labelFor(currentFile),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerSheet(BuildContext context, String currentFile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SoundPickerSheet(
        currentFile: currentFile,
        isPomodoro: isPomodoro,
      ),
    );
  }
}

class _SoundPickerSheet extends StatelessWidget {
  final String currentFile;
  final bool isPomodoro;

  const _SoundPickerSheet({
    required this.currentFile,
    required this.isPomodoro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPomodoro ? 'Pomodoro sound' : 'Break sound',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...AudioService.sounds.map((s) {
            final selected = s.file == currentFile;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final timer = context.read<TimerNotifier>();
                  if (isPomodoro) {
                    timer.setPomodoroSound(s.file);
                  } else {
                    timer.setBreakSound(s.file);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentLight
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.accent
                                : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        color: AppColors.accent,
                        onPressed: () =>
                            context.read<TimerNotifier>().previewSound(s.file),
                      ),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  const _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null || value > max) return oldValue;
    return newValue;
  }
}
