/// 休息 / Apple 健康授权偏好（本地标记）。
abstract class DeviceRepository {
  Future<bool> hasRequestedHealthAuthorization();
  Future<void> setHealthAuthorizationRequested(bool value);

  /// 一次性迁移：清除旧戒指本地键。
  Future<void> migrateFromRingIfNeeded();
}
