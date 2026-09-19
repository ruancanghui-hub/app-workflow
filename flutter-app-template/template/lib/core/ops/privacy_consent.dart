import '../storage/key_value_store.dart';

/// Local flag: user accepted the privacy policy (required before Umeng init in prod).
abstract final class PrivacyConsent {
  static const storageKey = 'privacy_policy_accepted';

  static Future<bool> isAccepted(KeyValueStore store) async =>
      (await store.getString(storageKey)) == '1';

  static Future<void> accept(KeyValueStore store) =>
      store.setString(storageKey, '1');

  static Future<void> reset(KeyValueStore store) => store.remove(storageKey);
}
