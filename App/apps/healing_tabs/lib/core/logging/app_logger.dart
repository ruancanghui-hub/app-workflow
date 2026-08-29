import '../ops/crash_reporter.dart';

abstract class AppLogger {
  void debug(String message);
  void error(String message, {Object? error, StackTrace? stack});
}

class ConsoleAppLogger implements AppLogger {
  ConsoleAppLogger({this.crashReporter, this.forwardErrors = true});

  final CrashReporter? crashReporter;
  final bool forwardErrors;

  final debugMessages = <String>[];
  final errorMessages = <String>[];

  @override
  void debug(String message) {
    debugMessages.add(message);
    // ignore: avoid_print
    print('[DEBUG] $message');
  }

  @override
  void error(String message, {Object? error, StackTrace? stack}) {
    errorMessages.add(message);
    // ignore: avoid_print
    print('[ERROR] $message');
    if (forwardErrors && crashReporter != null && error != null) {
      crashReporter!.recordError(error, stack);
    }
  }
}
