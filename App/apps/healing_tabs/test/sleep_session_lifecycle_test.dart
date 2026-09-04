import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/domain/models/sleep_session.dart';
import 'package:healing_tabs/features/sleep_session/sleep_session_lifecycle.dart';

void main() {
  group('SleepSessionLifecycle', () {
    test('auto closes after 16 hours', () {
      final startedAt = DateTime(2026, 3, 1, 22, 0);
      final now = startedAt.add(const Duration(hours: 16, minutes: 1));
      final session = SleepSession(id: '1', startedAt: startedAt);
      expect(SleepSessionLifecycle.shouldAutoClose(session, now), isTrue);
    });

    test('auto closes after next-day 10:00', () {
      final startedAt = DateTime(2026, 3, 1, 23, 0);
      final now = DateTime(2026, 3, 2, 10, 1);
      final session = SleepSession(id: '1', startedAt: startedAt);
      expect(SleepSessionLifecycle.shouldAutoClose(session, now), isTrue);
    });

    test('keeps active session within same night before deadline', () {
      final startedAt = DateTime(2026, 3, 1, 23, 0);
      final now = DateTime(2026, 3, 2, 2, 0);
      final session = SleepSession(id: '1', startedAt: startedAt);
      expect(SleepSessionLifecycle.shouldAutoClose(session, now), isFalse);
    });
  });
}
