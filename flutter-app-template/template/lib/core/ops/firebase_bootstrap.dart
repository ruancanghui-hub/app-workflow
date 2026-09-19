import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        await Firebase.initializeApp();
      }
      initialized = true;
      return true;
    } catch (e, st) {
      debugPrint('Firebase init skipped/failed: $e\n$st');
      return false;
    }
  }
}
