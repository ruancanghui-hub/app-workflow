abstract class DeviceRepository {
  Future<bool> isPaired();
  Future<void> setPaired(bool value);
}
