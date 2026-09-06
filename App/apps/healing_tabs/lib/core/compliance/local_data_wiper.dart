import '../storage/key_value_store.dart';
import 'privacy_consent.dart';

/// 清除本机云遥相关持久化数据（账号、睡眠、收藏、设备、心率、设置、同意）。
abstract final class LocalDataWiper {
  static const keys = <String>[
    'local_account_v1',
    'sleep_active_session_v1',
    'sleep_history_v1',
    'sound_favorites_v1',
    'device_paired_v1',
    'device_bound_v1',
    'device_metrics_v1',
    'meditation_hr_records_v1',
    'night_hr_series_v1',
    'settings_guest_v1',
    'settings_notify_v1',
    PrivacyConsent.storeKey,
  ];

  static Future<void> wipeAll(KeyValueStore store) async {
    for (final key in keys) {
      await store.remove(key);
    }
  }
}
