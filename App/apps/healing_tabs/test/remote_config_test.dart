import 'package:healing_tabs/core/ops/remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeRemoteConfig feature flag on/off', () {
    final config = FakeRemoteConfig({'demo_flag': true});
    expect(config.isFeatureEnabled('demo_flag'), isTrue);
    config.seed('demo_flag', false);
    expect(config.isFeatureEnabled('demo_flag'), isFalse);
  });
}
