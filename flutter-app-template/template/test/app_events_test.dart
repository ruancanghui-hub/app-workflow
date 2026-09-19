import 'package:app_template/core/ops/analytics.dart';
import 'package:app_template/core/ops/app_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppEvents logs typed names', () async {
    final analytics = FakeAnalytics();
    final events = AppEvents(analytics);

    await events.appOpen();
    await events.screenView('home');
    await events.jankDetected(buildMs: 40, rasterMs: 10);
    await events.diagnosticsOpen(source: 'secret_tap');
    await events.settingsDemoTap();
    await events.catalogDemoTap(action: 'toast_success');
    await events.onboardingComplete(version: '1');
    await events.ratingPrompt(action: 'positive');
    await events.feedbackSubmit(length: 12);

    expect(analytics.events.map((e) => e.name), [
      'app_open',
      'screen_view',
      'jank_detected',
      'diagnostics_open',
      'settings_demo_tap',
      'catalog_demo_tap',
      'onboarding_complete',
      'rating_prompt',
      'feedback_submit',
    ]);
    expect(analytics.events[analytics.events.length - 2].parameters['action'],
        'positive');
    expect(analytics.events.last.parameters['length'], 12);
  });
}
