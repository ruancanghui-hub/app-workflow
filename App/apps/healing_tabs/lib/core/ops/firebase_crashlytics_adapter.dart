import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'crash_reporter.dart';

class FirebaseCrashlyticsAdapter implements CrashReporter {
  FirebaseCrashlyticsAdapter({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    Map<String, Object?> context = const {},
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      error,
      stack,
      reason: context.isEmpty ? null : context.toString(),
      fatal: fatal,
    );
  }
}
