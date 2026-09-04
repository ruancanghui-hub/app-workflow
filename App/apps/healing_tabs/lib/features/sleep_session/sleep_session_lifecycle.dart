import '../../domain/models/sleep_session.dart';

/// Auto-close rules from ADR-0003: 16h cap + next-day 10:00.
abstract final class SleepSessionLifecycle {
  static const maxDuration = Duration(hours: 16);
  static const autoCloseHour = 10;

  static bool shouldAutoClose(SleepSession session, DateTime now) {
    if (session.status != SleepSessionStatus.active) return false;
    final elapsed = now.difference(session.startedAt);
    if (elapsed > maxDuration) return true;
    final deadline = nextAutoCloseTime(session.startedAt);
    return !now.isBefore(deadline);
  }

  static DateTime nextAutoCloseTime(DateTime startedAt) {
    final startDay = DateTime(
      startedAt.year,
      startedAt.month,
      startedAt.day,
    );
    return startDay.add(const Duration(days: 1, hours: autoCloseHour));
  }
}
