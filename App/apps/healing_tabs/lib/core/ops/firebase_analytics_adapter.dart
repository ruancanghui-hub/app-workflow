import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics.dart';

class FirebaseAnalyticsAdapter implements Analytics {
  FirebaseAnalyticsAdapter({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    final cleaned = <String, Object>{};
    parameters.forEach((key, value) {
      if (value != null) cleaned[key] = value;
    });
    return _analytics.logEvent(name: name, parameters: cleaned);
  }
}
