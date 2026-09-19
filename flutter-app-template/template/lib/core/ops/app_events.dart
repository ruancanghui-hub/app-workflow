import 'analytics.dart';

/// Typed **行为埋点** catalog for template-level events.
///
/// Business events belong in the template instance — extend or wrap this class.
class AppEvents {
  AppEvents(this._analytics);

  final Analytics _analytics;

  Future<void> appOpen() => _analytics.logEvent('app_open');

  Future<void> screenView(String screenName) => _analytics.logEvent(
        'screen_view',
        parameters: {'screen_name': screenName},
      );

  Future<void> jankDetected({
    required int buildMs,
    required int rasterMs,
  }) =>
      _analytics.logEvent(
        'jank_detected',
        parameters: {
          'build_ms': buildMs,
          'raster_ms': rasterMs,
        },
      );

  Future<void> diagnosticsOpen({required String source}) => _analytics.logEvent(
        'diagnostics_open',
        parameters: {'source': source},
      );

  Future<void> settingsDemoTap() => _analytics.logEvent(
        'settings_demo_tap',
        parameters: {'source': 'settings'},
      );

  Future<void> catalogDemoTap({required String action}) => _analytics.logEvent(
        'catalog_demo_tap',
        parameters: {'action': action},
      );

  Future<void> onboardingComplete({required String version}) =>
      _analytics.logEvent(
        'onboarding_complete',
        parameters: {'version': version},
      );

  Future<void> ratingPrompt({required String action}) => _analytics.logEvent(
        'rating_prompt',
        parameters: {'action': action},
      );

  Future<void> feedbackSubmit({required int length}) => _analytics.logEvent(
        'feedback_submit',
        parameters: {'length': length},
      );
}
