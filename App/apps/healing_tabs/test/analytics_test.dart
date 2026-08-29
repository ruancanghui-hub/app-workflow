import 'package:healing_tabs/core/ops/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeAnalytics records events', () async {
    final analytics = FakeAnalytics();
    await analytics.logEvent('tap', parameters: {'a': 1});
    expect(analytics.events.single.name, 'tap');
    expect(analytics.events.single.parameters['a'], 1);
  });
}
