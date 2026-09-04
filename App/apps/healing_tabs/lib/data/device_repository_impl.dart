import 'dart:convert';

import '../core/storage/key_value_store.dart';
import '../domain/models/bound_ring_device.dart';
import '../domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._store);

  static const _pairedKey = 'device_paired_v1';
  static const _boundKey = 'device_bound_v1';
  static const _metricsKey = 'device_metrics_v1';

  final KeyValueStore _store;
  bool? _cachedPaired;

  @override
  Future<bool> isPaired() async {
    if (_cachedPaired != null) return _cachedPaired!;
    final raw = await _store.getString(_pairedKey);
    _cachedPaired = raw == 'true';
    return _cachedPaired!;
  }

  @override
  Future<void> setPaired(bool value) async {
    _cachedPaired = value;
    await _store.setString(_pairedKey, value.toString());
    if (!value) {
      await clearBoundDevice();
      await clearCachedMetrics();
    }
  }

  @override
  Future<BoundRingDevice?> getBoundDevice() async {
    final raw = await _store.getString(_boundKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return BoundRingDevice.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveBoundDevice(BoundRingDevice device) async {
    await _store.setString(_boundKey, jsonEncode(device.toJson()));
  }

  @override
  Future<void> clearBoundDevice() async {
    await _store.remove(_boundKey);
  }

  @override
  Future<CachedDeviceMetrics?> getCachedMetrics() async {
    final raw = await _store.getString(_metricsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CachedDeviceMetrics.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedMetrics(CachedDeviceMetrics metrics) async {
    await _store.setString(_metricsKey, jsonEncode(metrics.toJson()));
  }

  @override
  Future<void> clearCachedMetrics() async {
    await _store.remove(_metricsKey);
  }
}
