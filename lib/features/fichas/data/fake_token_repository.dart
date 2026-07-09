import '../domain/token_date.dart';
import '../domain/token_models.dart';
import '../domain/token_repository.dart';

/// In-memory [TokenRepository] for Fase B1. Seeded to mirror the mock data so
/// the screens behave the same, but now driven by real logic. Swapped for a
/// Drift-backed implementation in Fase B2 — no UI changes required.
///
/// Note: data lives only in memory, so it resets on app restart. Persistence
/// across restarts arrives with Drift in B2.
class FakeTokenRepository implements TokenRepository {
  TokenTemplate _template = _seedTemplate();
  final Map<String, Set<String>> _logs = {};
  final Set<String> _claims = {};

  FakeTokenRepository() {
    _seedLogs();
  }

  static TokenTemplate _seedTemplate() => const TokenTemplate(
    tasks: [
      Task(id: 't1', name: 'Write 500 words'),
      Task(id: 't2', name: 'Deep work block'),
      Task(id: 't3', name: 'Exercise'),
      Task(id: 't4', name: 'Read 20 min'),
      Task(id: 't5', name: 'Review project'),
    ],
    daysPerWeek: 5,
    weekStartDay: DateTime.monday,
    weeklyGoal: 18,
    reward: 'Dinner out 🍽️',
  );

  // Seeds ~13 tokens across earlier days of the week plus 2 today, so the
  // weekly goal (18) is reachable by checking off today's remaining tasks.
  void _seedLogs() {
    final today = dayOnly(DateTime.now());
    _logs[dayKey(today)] = {'t1', 't2'};
    _logs[dayKey(today.subtract(const Duration(days: 1)))] = {
      't1',
      't2',
      't3',
      't4',
      't5',
    };
    _logs[dayKey(today.subtract(const Duration(days: 2)))] = {
      't1',
      't2',
      't3',
      't4',
      't5',
    };
    _logs[dayKey(today.subtract(const Duration(days: 3)))] = {'t1', 't2', 't3'};
  }

  @override
  Future<TokenTemplate> loadTemplate() async => _template;

  @override
  Future<void> saveTemplate(TokenTemplate template) async =>
      _template = template;

  @override
  Future<List<DayLog>> logsForWeek(DateTime weekStart) async {
    final end = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);
    final result = <DayLog>[];
    _logs.forEach((k, ids) {
      final d = parseDayKey(k);
      if (!d.isBefore(weekStart) && d.isBefore(end)) {
        result.add(DayLog(date: d, completedTaskIds: {...ids}));
      }
    });
    return result;
  }

  @override
  Future<void> setTaskCompleted(
    DateTime day,
    String taskId,
    bool completed,
  ) async {
    final set = _logs.putIfAbsent(dayKey(day), () => <String>{});
    if (completed) {
      set.add(taskId);
    } else {
      set.remove(taskId);
    }
  }

  @override
  Future<bool> isRewardClaimed(DateTime weekStart) async =>
      _claims.contains(dayKey(weekStart));

  @override
  Future<void> setRewardClaimed(DateTime weekStart) async =>
      _claims.add(dayKey(weekStart));
}
