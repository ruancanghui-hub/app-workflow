abstract class SettingsRepository {
  Future<bool> isGuestMode();
  Future<void> setGuestMode(bool value);
  Future<bool> notificationsEnabled();
  Future<void> setNotificationsEnabled(bool value);
}
