import '../storage/key_value_store.dart';

/// First-run / major-update gate for the 引导页.
abstract final class OnboardingGate {
  static const seenVersionKey = 'onboarding_seen_version';

  /// Shows onboarding when the stored version differs from [version].
  static Future<bool> shouldShow(KeyValueStore store, String version) async {
    final seen = await store.getString(seenVersionKey);
    return seen != version;
  }

  static Future<void> markSeen(KeyValueStore store, String version) =>
      store.setString(seenVersionKey, version);

  static Future<void> reset(KeyValueStore store) =>
      store.remove(seenVersionKey);
}
