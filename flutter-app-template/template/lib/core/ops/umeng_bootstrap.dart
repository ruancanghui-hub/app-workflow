import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../env/app_environment.dart';
import '../storage/key_value_store.dart';
import 'privacy_consent.dart';
import 'umeng_config.dart';

/// Initializes 友盟统计 after privacy rules allow it.
///
/// - **dev**: init as soon as [UmengConfig.hasKeys].
/// - **prod**: requires [PrivacyConsent] accepted first; instances call
///   [AppBindings.enableUmengAfterPrivacyConsent] after the real privacy UI.
class UmengBootstrap {
  UmengBootstrap({required this.config});

  final UmengConfig config;

  var _initialized = false;

  bool get isInitialized => _initialized;

  /// Optional override for tests (avoids touching the native plugin).
  Future<void> Function(String android, String ios, String channel)? initOverride;

  Future<bool> tryInit({
    required AppEnvironment environment,
    required KeyValueStore store,
  }) async {
    if (_initialized) return true;
    if (!config.hasKeys) return false;
    if (environment.isProd && !await PrivacyConsent.isAccepted(store)) {
      return false;
    }

    final android = config.androidAppKey.trim();
    final ios = config.iosAppKey.trim();
    final channel =
        config.channel.trim().isEmpty ? 'Flutter' : config.channel.trim();

    final init = initOverride ??
        (a, i, c) => UmengCommonSdk.initCommon(a, i, c);
    await init(android, ios, channel);
    _initialized = true;
    return true;
  }
}
