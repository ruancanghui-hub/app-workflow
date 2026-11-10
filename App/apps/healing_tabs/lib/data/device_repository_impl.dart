import '../core/storage/key_value_store.dart';
import '../domain/repositories/device_repository.dart';
import 'health/apple_health_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._store);

  static const _migrationKey = 'ring_to_health_migrated_v1';

  /// 旧戒指本地存储键（升级时一次性清除）。
  static const ringLegacyKeys = <String>[
    'device_paired_v1',
    'device_bound_v1',
    'device_metrics_v1',
    'meditation_hr_records_v1',
    'night_hr_series_v1',
  ];

  final KeyValueStore _store;

  @override
  Future<bool> hasRequestedHealthAuthorization() async {
    final raw = await _store.getString(AppleHealthRepository.authRequestedKey);
    return raw == 'true';
  }

  @override
  Future<void> setHealthAuthorizationRequested(bool value) async {
    await _store.setString(
      AppleHealthRepository.authRequestedKey,
      value.toString(),
    );
  }

  @override
  Future<void> migrateFromRingIfNeeded() async {
    final done = await _store.getString(_migrationKey);
    if (done == 'true') return;
    for (final key in ringLegacyKeys) {
      await _store.remove(key);
    }
    await _store.setString(_migrationKey, 'true');
  }
}
