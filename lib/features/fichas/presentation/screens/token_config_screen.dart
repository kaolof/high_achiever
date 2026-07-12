import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../data/token_backup_service.dart';
import '../../domain/token_backup.dart';
import '../../domain/token_models.dart';
import '../../domain/token_system_notifier.dart';

/// Fase A2 (wired to real state in Fase B1).
///
/// Loads the current template from [TokenSystemNotifier], edits it locally, and
/// on save writes it back through `updateTemplate` — which now actually drives
/// the main screen.
class TokenConfigScreen extends StatefulWidget {
  const TokenConfigScreen({super.key});

  @override
  State<TokenConfigScreen> createState() => _TokenConfigScreenState();
}

class _TokenConfigScreenState extends State<TokenConfigScreen> {
  final List<_TaskDraft> _tasks = [];
  final TextEditingController _rewardController = TextEditingController();
  final TokenBackupService _backup = TokenBackupService();
  int _daysPerWeek = 5;
  int _weekStartDay = 1; // 1 = Monday … 7 = Sunday
  int _weeklyGoal = 18;
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    final t = context.read<TokenSystemNotifier>().template;
    for (final task in t.tasks) {
      _tasks.add(
        _TaskDraft(
          id: task.id,
          controller: TextEditingController(text: task.name),
        ),
      );
    }
    _daysPerWeek = t.daysPerWeek;
    _weekStartDay = t.weekStartDay;
    _weeklyGoal = t.weeklyGoal;
    _rewardController.text = t.reward;
  }

  int get _taskCount => _tasks.length;
  int get _maxTokens => _taskCount * _daysPerWeek;

  @override
  void dispose() {
    for (final d in _tasks) {
      d.controller.dispose();
    }
    _rewardController.dispose();
    super.dispose();
  }

  void _addTask() => setState(
    () => _tasks.add(
      _TaskDraft(id: _newTaskId(), controller: TextEditingController()),
    ),
  );

  // Unique across sessions. An id derived from the task count could be reused
  // after a delete, colliding with an existing task's completions (shared
  // toggle state) and breaking saveTemplate's UNIQUE constraint on a re-add.
  String _newTaskId() =>
      'task_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  void _removeTask(int i) {
    setState(() {
      _tasks.removeAt(i).controller.dispose();
      _clampGoal();
    });
  }

  void _setDaysPerWeek(int v) => setState(() {
    _daysPerWeek = v;
    _clampGoal();
  });

  void _clampGoal() {
    _weeklyGoal = _weeklyGoal.clamp(1, _maxTokens == 0 ? 1 : _maxTokens);
  }

  void _save() {
    final tasks = [
      for (final d in _tasks)
        Task(
          id: d.id,
          name: d.controller.text.trim().isEmpty
              ? 'Untitled'
              : d.controller.text.trim(),
        ),
    ];
    final template = TokenTemplate(
      tasks: tasks,
      daysPerWeek: _daysPerWeek,
      weekStartDay: _weekStartDay,
      weeklyGoal: _weeklyGoal.clamp(1, tasks.length * _daysPerWeek),
      reward: _rewardController.text.trim(),
    );
    context.read<TokenSystemNotifier>().updateTemplate(template);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(_snack('Template saved'));
    Navigator.pop(context);
  }

  SnackBar _snack(String message, {bool error = false}) =>
      appSnackBar(message: message, error: error);

  // ── Backup ─────────────────────────────────────────────────────────────────

  Future<void> _exportBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = context.read<TokenSystemNotifier>();
    // iPad presents the share sheet as a popover and needs an anchor rect;
    // anchor it to this screen's bounds.
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null && box.hasSize)
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    try {
      final backup = await notifier.exportBackup();
      await _backup.exportToShare(
        backup,
        now: DateTime.now(),
        sharePositionOrigin: origin,
      );
    } catch (_) {
      messenger.showSnackBar(_snack('Could not export backup', error: true));
    }
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final notifier = context.read<TokenSystemNotifier>();

    final TokenBackup? backup;
    try {
      backup = await _backup.pickAndDecode();
    } on TokenBackupFormatException catch (e) {
      messenger.showSnackBar(_snack(e.message, error: true));
      return;
    } catch (_) {
      messenger.showSnackBar(_snack('Could not read the file', error: true));
      return;
    }
    if (backup == null) return; // user cancelled the picker
    if (!mounted) return;

    final confirmed = await _confirmImport(backup);
    if (confirmed != true) return;

    try {
      await notifier.importBackup(backup);
    } catch (_) {
      messenger.showSnackBar(_snack('Could not import backup', error: true));
      return;
    }
    if (!mounted) return;
    messenger.showSnackBar(_snack('Backup imported'));
    // Leave config: the local drafts still hold the old template, and the main
    // screen reads fresh state straight from the notifier.
    navigator.pop();
  }

  Future<bool?> _confirmImport(TokenBackup backup) {
    final tasks = backup.template.tasks.length;
    final completions = backup.completions.length;
    final weeks = backup.claimedWeeks.length;
    return showConfirmDialog(
      context,
      title: 'Import backup?',
      message:
          'This replaces your current tokens data with:\n\n'
          '•  $tasks tasks\n'
          '•  $completions completions logged\n'
          '•  $weeks weeks claimed\n\n'
          "Your current data will be lost. This can't be undone.",
      confirmLabel: 'Import',
      destructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Configure',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Live max summary ────────────────────────────────────────────
          _MaxBanner(tasks: _taskCount, days: _daysPerWeek, max: _maxTokens),
          const SizedBox(height: 24),

          // ── Tasks ───────────────────────────────────────────────────────
          const _SectionLabel('DAILY TASKS'),
          const SizedBox(height: 10),
          _Card(
            child: Column(
              children: [
                for (int i = 0; i < _tasks.length; i++) ...[
                  _TaskEditRow(
                    controller: _tasks[i].controller,
                    canDelete: _tasks.length > 1,
                    onDelete: () => _removeTask(i),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.surfaceContainerLow,
                  ),
                ],
                _AddTaskRow(onTap: _addTask),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Schedule ────────────────────────────────────────────────────
          const _SectionLabel('SCHEDULE'),
          const SizedBox(height: 10),
          _Card(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              children: [
                _RowStepper(
                  label: 'Days per week',
                  value: _daysPerWeek,
                  min: 1,
                  max: 7,
                  onChanged: _setDaysPerWeek,
                ),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Week starts on',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _WeekStartSelector(
                  selected: _weekStartDay,
                  onChanged: (d) => setState(() => _weekStartDay = d),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Goal & reward ───────────────────────────────────────────────
          const _SectionLabel('GOAL & REWARD'),
          const SizedBox(height: 10),
          _Card(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              children: [
                _RowStepper(
                  label: 'Weekly goal',
                  value: _weeklyGoal,
                  min: 1,
                  max: _maxTokens == 0 ? 1 : _maxTokens,
                  suffix: ' / $_maxTokens',
                  onChanged: (v) => setState(() => _weeklyGoal = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _rewardController,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Reward',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    prefixIcon: const Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Backup ──────────────────────────────────────────────────────
          const _SectionLabel('BACKUP'),
          const SizedBox(height: 10),
          _Card(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                _BackupRow(
                  icon: Icons.upload_rounded,
                  title: 'Export backup',
                  subtitle: 'Save your tokens to a file (Drive, email…)',
                  onTap: _exportBackup,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                  color: AppColors.surfaceContainerLow,
                ),
                _BackupRow(
                  icon: Icons.download_rounded,
                  title: 'Import backup',
                  subtitle: 'Restore from a file (replaces current data)',
                  onTap: _importBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _SaveButton(onTap: _save),
        ],
      ),
    );
  }
}

class _TaskDraft {
  final String id;
  final TextEditingController controller;
  _TaskDraft({required this.id, required this.controller});
}

// ── Live "max tokens" banner ─────────────────────────────────────────────────
class _MaxBanner extends StatelessWidget {
  final int tasks;
  final int days;
  final int max;

  const _MaxBanner({
    required this.tasks,
    required this.days,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$max',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'MAX TOKENS / WEEK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$tasks tasks\n× $days days',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable pieces ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Card({required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _TaskEditRow extends StatelessWidget {
  final TextEditingController controller;
  final bool canDelete;
  final VoidCallback onDelete;

  const _TaskEditRow({
    required this.controller,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          const Icon(
            Icons.drag_indicator_rounded,
            color: AppColors.outlineVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Task name',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          IconButton(
            onPressed: canDelete ? onDelete : null,
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              color: canDelete
                  ? AppColors.textSecondary
                  : AppColors.outlineVariant,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskRow extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTaskRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 12),
            Text(
              'Add task',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BackupRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String? suffix;
  final ValueChanged<int> onChanged;

  const _RowStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 56),
          alignment: Alignment.center,
          child: Text(
            '$value${suffix ?? ''}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add_rounded,
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }
}

class _WeekStartSelector extends StatelessWidget {
  final int selected; // 1..7
  final ValueChanged<int> onChanged;

  const _WeekStartSelector({required this.selected, required this.onChanged});

  static const _labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onChanged(i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i + 1
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      color: selected == i + 1
                          ? AppColors.surfaceContainerLowest
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              color: AppColors.surfaceContainerLowest,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Save template',
              style: TextStyle(
                color: AppColors.surfaceContainerLowest,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
