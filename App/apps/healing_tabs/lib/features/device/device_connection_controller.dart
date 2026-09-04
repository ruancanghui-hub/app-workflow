import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../data/ble/yc_ble_ring_service.dart';
import '../../domain/models/bound_ring_device.dart';
import '../../domain/models/device_content.dart';
import '../../domain/repositories/device_repository.dart';
import '../tabs/device/device_content_catalog.dart';

class DeviceConnectionController extends GetxController {
  DeviceConnectionController({
    required DeviceRepository deviceRepository,
    required YcBleRingService ble,
  })  : _deviceRepository = deviceRepository,
        _ble = ble;

  final DeviceRepository _deviceRepository;
  final YcBleRingService _ble;

  final paired = false.obs;
  final connected = false.obs;
  final syncing = false.obs;
  final snapshot = DeviceContentCatalog.unpairedSnapshot.obs;
  final statusMessage = ''.obs;

  Worker? _bleWorker;

  bool get isPaired => paired.value;

  @override
  void onInit() {
    super.onInit();
    _bleWorker = ever<int>(_ble.bluetoothState, (st) {
      connected.value = st == BluetoothState.connected;
      if (paired.value) {
        unawaited(_rebuildSnapshot());
        if (st == BluetoothState.connected) {
          unawaited(refreshFromDevice());
        }
      }
    });
    unawaited(_bootstrap());
  }

  @override
  void onClose() {
    _bleWorker?.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await loadPairedState();
    try {
      await _ble.ensureInitialized();
    } catch (e, st) {
      debugPrint('BLE init failed: $e\n$st');
    }
    if (!paired.value) return;
    unawaited(_tryReconnect());
  }

  Future<void> loadPairedState() async {
    paired.value = await _deviceRepository.isPaired();
    connected.value = _ble.isConnected.value;
    await _rebuildSnapshot();
  }

  Future<void> pairWith(BluetoothDevice device) async {
    statusMessage.value = '正在连接…';
    final ok = await _ble.connect(device);
    if (!ok) {
      statusMessage.value = '连接失败，请重试';
      throw StateError('连接失败');
    }
    final bound = BoundRingDevice(
      macAddress: device.macAddress,
      deviceIdentifier: device.deviceIdentifier,
      name: device.name,
      rssiValue: device.rssiValue,
      deviceModel: device.deviceModel,
    );
    await _deviceRepository.saveBoundDevice(bound);
    await _deviceRepository.setPaired(true);
    paired.value = true;
    connected.value = true;
    statusMessage.value = '已连接，正在同步…';
    await refreshFromDevice();
    statusMessage.value = '';
  }

  Future<void> unpair() async {
    try {
      await _ble.disconnect();
    } catch (e, st) {
      debugPrint('disconnect failed: $e\n$st');
    }
    await _deviceRepository.setPaired(false);
    paired.value = false;
    connected.value = false;
    snapshot.value = DeviceContentCatalog.unpairedSnapshot;
    statusMessage.value = '';
  }

  /// 兼容旧调用名。
  Future<void> unpairDemo() => unpair();

  Future<void> pair() async {
    // 扫描页应调用 [pairWith]；保留空实现避免旧调用崩溃。
  }

  Future<void> refreshFromDevice() async {
    if (!paired.value || !_ble.isConnected.value) return;
    syncing.value = true;
    try {
      final metrics = await _ble.syncMetrics(
        fallbackBattery: snapshot.value.device.batteryPercent,
      );
      await _deviceRepository.saveCachedMetrics(metrics);
      await _rebuildSnapshot();
    } catch (e, st) {
      debugPrint('refreshFromDevice failed: $e\n$st');
    } finally {
      syncing.value = false;
    }
  }

  Future<void> _tryReconnect() async {
    final bound = await _deviceRepository.getBoundDevice();
    if (bound == null) return;
    statusMessage.value = '正在重连…';
    try {
      final ok = await _ble.connectBound(bound);
      connected.value = ok;
      if (ok) {
        await refreshFromDevice();
      } else {
        await _rebuildSnapshot();
      }
    } catch (e, st) {
      debugPrint('reconnect failed: $e\n$st');
      await _rebuildSnapshot();
    } finally {
      statusMessage.value = '';
    }
  }

  Future<void> _rebuildSnapshot() async {
    if (!paired.value) {
      snapshot.value = DeviceContentCatalog.unpairedSnapshot;
      return;
    }
    final bound = await _deviceRepository.getBoundDevice();
    final metrics = await _deviceRepository.getCachedMetrics();
    final name = bound?.displayName ?? '云遥戒指';
    final battery = metrics?.batteryPercent ?? 0;
    final state = syncing.value
        ? DeviceConnectionState.syncing
        : connected.value
            ? DeviceConnectionState.connected
            : DeviceConnectionState.connecting;

    NightSleepSummary? sleep;
    if (metrics?.sleepDuration != null &&
        metrics!.qualityLabel != null &&
        metrics.insight != null &&
        metrics.score != null) {
      sleep = NightSleepSummary(
        duration: metrics.sleepDuration!,
        qualityLabel: metrics.qualityLabel!,
        insight: metrics.insight!,
        score: metrics.score!,
      );
    }

    HeartRateReading? heart;
    if (metrics?.heartRateBpm != null && metrics!.heartRateBpm! > 0) {
      heart = HeartRateReading(
        bpm: metrics.heartRateBpm!,
        kindLabel: '心率',
        baselineHint: '来自戒指同步',
      );
    }

    final hasVitals = sleep != null || heart != null;
    snapshot.value = DeviceDaySnapshot(
      device: RingDevice(
        id: bound?.deviceIdentifier.isNotEmpty == true
            ? bound!.deviceIdentifier
            : (bound?.macAddress ?? 'ring'),
        displayName: name,
        connectionState: state,
        batteryPercent: battery,
      ),
      headline: hasVitals
          ? [
              if (sleep != null) '昨夜睡眠${sleep.qualityLabel}',
              if (heart != null) '心率 ${heart.bpm} bpm',
            ].join(' · ')
          : (connected.value ? '已连接，等待同步睡眠与心率' : '已绑定，等待重新连接'),
      sleep: sleep,
      heartRate: heart,
    );
  }
}
