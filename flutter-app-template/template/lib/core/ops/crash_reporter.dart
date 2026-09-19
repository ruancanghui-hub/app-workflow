abstract class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
    bool fatal = false,
  });
}

class FakeCrashReporter implements CrashReporter {
  final reports = <({Object error, StackTrace? stack, bool fatal})>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
    bool fatal = false,
  }) async {
    reports.add((error: error, stack: stack, fatal: fatal));
  }
}
