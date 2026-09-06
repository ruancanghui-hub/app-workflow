import '../storage/key_value_store.dart';

/// 首次隐私同意与本机合规相关键。
abstract final class PrivacyConsent {
  static const storeKey = 'privacy_consent_v1';

  static Future<bool> hasConsented(KeyValueStore store) async {
    final raw = await store.getString(storeKey);
    return raw == 'true';
  }

  static Future<void> setConsented(KeyValueStore store, {required bool value}) {
    return store.setString(storeKey, value ? 'true' : 'false');
  }
}
