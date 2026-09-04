import '../models/bound_ring_device.dart';

abstract class DeviceRepository {
  Future<bool> isPaired();
  Future<void> setPaired(bool value);

  Future<BoundRingDevice?> getBoundDevice();
  Future<void> saveBoundDevice(BoundRingDevice device);
  Future<void> clearBoundDevice();

  Future<CachedDeviceMetrics?> getCachedMetrics();
  Future<void> saveCachedMetrics(CachedDeviceMetrics metrics);
  Future<void> clearCachedMetrics();
}
