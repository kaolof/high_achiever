// Date helpers shared across the token system (week math, day keys).

/// Strips time, keeping year/month/day at midnight.
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Stable string key for a day, e.g. "2026-07-09".
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// The most recent [weekStartDay] (1 = Mon … 7 = Sun) on or before [day].
DateTime weekStartFor(DateTime day, int weekStartDay) {
  final d = dayOnly(day);
  final diff = (d.weekday - weekStartDay + 7) % 7;
  // Calendar arithmetic (not Duration) so DST-length days don't shift the date.
  return DateTime(d.year, d.month, d.day - diff);
}
