import 'package:healing_tabs/core/ops/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeCrashReporter records errors', () async {
    final reporter = FakeCrashReporter();
    await reporter.recordError(StateError('x'), StackTrace.current);
    expect(reporter.reports, hasLength(1));
  });
}
