import 'package:app_template/core/ops/diagnostics_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SecretTapDetector trips after required taps', () {
    final detector = SecretTapDetector(requiredTaps: 3);

    expect(detector.registerTap(), isFalse);
    expect(detector.registerTap(), isFalse);
    expect(detector.registerTap(), isTrue);
    expect(detector.registerTap(), isFalse);
  });
}
