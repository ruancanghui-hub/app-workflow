import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'firebase_config_detector.dart';

/// Conditionally initializes Firebase when configuration is present.
class FirebaseBootstrap {
  FirebaseBootstrap({
    this.detector = const FirebaseConfigDetector(),
    this.initializeFn,
  });

  final FirebaseConfigDetector detector;
  final Future<FirebaseApp> Function()? initializeFn;

  bool initialized = false;

  Future<bool> ensureInitialized() async {
    if (!detector.isConfigured) {
      return false;
    }
    try {
      if (initializeFn != null) {
        await initializeFn!();
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      // 将未捕获 Flutter / 平台错误送入 Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      initialized = true;
      return true;
    } catch (e, st) {
      debugPrint('Firebase init skipped/failed: $e\n$st');
      return false;
    }
  }
}
