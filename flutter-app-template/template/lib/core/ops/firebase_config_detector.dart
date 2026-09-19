/// Detects whether Firebase should initialize.
///
/// Set `--dart-define=FIREBASE_CONFIGURED=true` after adding local Firebase
/// options / google-services files. Default is false (no-op path).
class FirebaseConfigDetector {
  const FirebaseConfigDetector();

  static const configuredFlag = String.fromEnvironment(
    'FIREBASE_CONFIGURED',
    defaultValue: 'false',
  );

  bool get isConfigured => configuredFlag.toLowerCase() == 'true';
}
