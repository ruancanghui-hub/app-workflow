import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'analytics.dart';

/// [Analytics] adapter backed by 友盟 (`umeng_common_sdk`).
class UmengAnalyticsAdapter implements Analytics {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final props = <String, dynamic>{};
    parameters.forEach((key, value) {
      if (value != null) props[key] = value;
    });
    UmengCommonSdk.onEvent(name, props);
  }
}
