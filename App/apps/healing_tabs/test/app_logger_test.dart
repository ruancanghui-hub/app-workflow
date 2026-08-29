import 'package:healing_tabs/core/logging/app_logger.dart';
import 'package:healing_tabs/core/ops/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConsoleAppLogger stores debug messages', () {
    final logger = ConsoleAppLogger(forwardErrors: false);
    logger.debug('hi');
    expect(logger.debugMessages, ['hi']);
  });

  test('ConsoleAppLogger forwards errors to CrashReporter', () {
    final crash = FakeCrashReporter();
    final logger = ConsoleAppLogger(crashReporter: crash);
    logger.error('boom', error: StateError('e'), stack: StackTrace.current);
    expect(crash.reports, hasLength(1));
  });
}
