import 'package:healing_tabs/core/ops/firebase_config_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FirebaseConfigDetector defaults to not configured', () {
    expect(const FirebaseConfigDetector().isConfigured, isFalse);
  });
}
