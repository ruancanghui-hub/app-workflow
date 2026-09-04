import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../domain/models/bound_ring_device.dart';
import '../../domain/models/device_content.dart';

/// 云程戒指 BLE 网关：扫描 / 连接 / 基础信息与睡眠心率同步。
class YcBleRingService extends GetxService {
  final pluginReady = false.obs;
  final bluetoothState = BluetoothState.off.obs;
  final isConnected = false.obs;

  bool _listening = false;

  Future<void> ensureInitialized() async {
    if (pluginReady.value) return;
    await YcProductPlugin().initPlugin(
      isReconnectEnable: true,
      isLogEnable: kDebugMode,
    );
    if (!_listening) {
      YcProductPlugin().onListening(_handleNativeEvent);
      _listening = true;
    }
    pluginReady.value = true;
  }

  void _handleNativeEvent(dynamic event) {
    if (event is! Map) return;
    if (!event.containsKey(NativeEventType.bluetoothStateChange)) return;
    final st = event[NativeEventType.bluetoothStateChange];
    if (st is! int) return;
    bluetoothState.value = st;
    isConnected.value = st == BluetoothState.connected;
  }

  /// 请求扫描所需权限；失败返回 false。
  Future<bool> ensureScanPermissions() async {
    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      if (!scan.isGranted || !connect.isGranted) {
        // Android 11 及以下可能没有上述权限，退回定位。
        final location = await Permission.locationWhenInUse.request();
        if (!location.isGranted) return false;
      } else {
        // 部分机型仍要求定位权限才能扫到 BLE。
        final location = await Permission.locationWhenInUse.request();
        if (!location.isGranted) return false;
      }
    } else {
      final bluetooth = await Permission.bluetooth.request();
      if (!bluetooth.isGranted && !bluetooth.isLimited) {
        return false;
      }
    }
    return true;
  }

  Future<List<BluetoothDevice>> scanDevices({int time = 6}) async {
    await ensureInitialized();
    final granted = await ensureScanPermissions();
    if (!granted) {
      throw StateError('缺少蓝牙或定位权限，无法扫描设备');
    }
    if (Platform.isAndroid) {
      unawaited(
        YcProductPlugin()
            .setReconnectEnabled(isReconnectEnable: false)
            .catchError((_) => null),
      );
    }
    await YcProductPlugin().stopScanDevice();
    final list = await YcProductPlugin().scanDevice(
      time: Platform.isAndroid ? (time < 6 ? 6 : time) : time,
    );
    final devices = list ?? <BluetoothDevice>[];
    // 按 mac / identifierIdentifier 去重，信号强的优先。
    final byId = <String, BluetoothDevice>{};
    for (final d in devices) {
      final id = d.deviceIdentifier.isNotEmpty
          ? d.deviceIdentifier
          : d.macAddress;
      if (id.isEmpty) continue;
      final existing = byId[id];
      if (existing == null || d.rssiValue > existing.rssiValue) {
        byId[id] = d;
      }
    }
    final unique = byId.values.toList()
      ..sort((a, b) => b.rssiValue.compareTo(a.rssiValue));
    return unique;
  }

  Future<void> stopScan() async {
    await YcProductPlugin().stopScanDevice();
  }

  Future<bool> connect(BluetoothDevice device) async {
    await ensureInitialized();
    await ensureScanPermissions();

    final targetMac = _normalizeMac(
      device.deviceIdentifier.isNotEmpty
          ? device.deviceIdentifier
          : device.macAddress,
    );
    if (targetMac.isEmpty) {
      debugPrint('[BLE] connect aborted: empty mac');
      return false;
    }

    debugPrint(
      '[BLE] connect start name=${device.name} mac=$targetMac '
      'state=${bluetoothState.value} '
      'pluginDevice=${YcProductPlugin().connectedDevice?.macAddress}',
    );

    // 已连通且就是目标设备：直接成功，避免 resetBond / 再连打乱状态。
    if (_isLinkedTo(targetMac)) {
      debugPrint('[BLE] connect success (already linked) mac=$targetMac');
      return _finishConnected();
    }

    if (Platform.isAndroid) {
      await YcProductPlugin()
          .setReconnectEnabled(isReconnectEnable: false)
          .catchError((_) => null);
    }

    // 已连其它设备时先断开。
    final current = YcProductPlugin().connectedDevice;
    final currentMac = _normalizeMac(
      current?.deviceIdentifier.isNotEmpty == true
          ? current!.deviceIdentifier
          : (current?.macAddress ?? ''),
    );
    if (currentMac.isNotEmpty && currentMac != targetMac) {
      debugPrint('[BLE] disconnect other device $currentMac before $targetMac');
      try {
        await YcProductPlugin().disconnectDevice();
      } catch (e, st) {
        debugPrint('[BLE] disconnect other failed: $e\n$st');
      }
      isConnected.value = false;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    await YcProductPlugin().clearQueue();
    await YcProductPlugin().stopScanDevice();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // 仅在未连目标时 resetBond。
    if (!_isLinkedTo(targetMac)) {
      await YcProductPlugin().resetBond();
    }

    // 发起连接；MethodChannel 常挂死，成败以轮询 MAC 为准。
    unawaited(
      YcProductPlugin().connectDevice(device).then((raw) {
        debugPrint('[BLE] connectDevice raw=$raw mac=$targetMac');
      }).catchError((Object e, StackTrace st) {
        debugPrint('[BLE] connectDevice error: $e\n$st');
      }),
    );

    final ok = await _waitUntilLinked(
      targetMac: targetMac,
      timeout: const Duration(seconds: 20),
    );

    if (ok) {
      debugPrint('[BLE] connect success mac=$targetMac');
      return _finishConnected();
    }

    debugPrint(
      '[BLE] connect give up mac=$targetMac '
      'state=${bluetoothState.value} '
      'pluginDevice=${YcProductPlugin().connectedDevice?.macAddress}',
    );
    return false;
  }

  Future<bool> _finishConnected() async {
    isConnected.value = true;
    bluetoothState.value = BluetoothState.connected;
    try {
      await YcProductPlugin()
          .setDeviceSyncPhoneTime()
          .timeout(const Duration(seconds: 3));
    } catch (e, st) {
      debugPrint('[BLE] setDeviceSyncPhoneTime skipped: $e\n$st');
    }
    return true;
  }

  /// 轮询：只查 state / connectedDevice / 短超时 getBluetoothState，不查健康数据。
  Future<bool> _waitUntilLinked({
    required String targetMac,
    required Duration timeout,
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (_isLinkedTo(targetMac)) return true;
      try {
        final st = await YcProductPlugin()
            .getBluetoothState()
            .timeout(const Duration(seconds: 2));
        if (st != null) {
          bluetoothState.value = st;
          isConnected.value = st == BluetoothState.connected;
        }
        if (_isLinkedTo(targetMac)) return true;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    return _isLinkedTo(targetMac);
  }

  bool _isLinkedTo(String targetMac) {
    if (targetMac.isEmpty) return false;
    final plugin = YcProductPlugin().connectedDevice;
    if (plugin == null) return false;
    final pluginMac = _normalizeMac(
      plugin.deviceIdentifier.isNotEmpty
          ? plugin.deviceIdentifier
          : plugin.macAddress,
    );
    return pluginMac.isNotEmpty && pluginMac == targetMac;
  }

  static String _normalizeMac(String raw) =>
      raw.trim().toUpperCase().replaceAll('-', ':');

  Future<bool> connectBound(BoundRingDevice bound) async {
    final device = BluetoothDevice.formJson(bound.toJson());
    return connect(device);
  }

  Future<void> disconnect() async {
    await ensureInitialized();
    await YcProductPlugin().disconnectDevice();
    isConnected.value = false;
  }

  Future<DeviceBasicInfo?> queryBasicInfo() async {
    final response = await YcProductPlugin().queryDeviceBasicInfo();
    if (response == null || response.statusCode != PluginState.succeed) {
      return null;
    }
    return response.data;
  }

  /// 拉取昨夜睡眠 + 最近心率，组装为 Tab 可用摘要。
  Future<CachedDeviceMetrics> syncMetrics({int fallbackBattery = 0}) async {
    var battery = fallbackBattery;
    final basic = await queryBasicInfo();
    if (basic != null) {
      battery = basic.batteryPower;
    }

    NightSleepSummary? sleep;
    final sleepResp =
        await YcProductPlugin().queryDeviceHealthData(HealthDataType.sleep);
    if (sleepResp != null && sleepResp.statusCode == PluginState.succeed) {
      final rows = sleepResp.data.whereType<SleepDataInfo>().toList();
      if (rows.isNotEmpty) {
        rows.sort((a, b) => b.endTimeStamp.compareTo(a.endTimeStamp));
        sleep = _summarizeSleep(rows.first);
      }
    }

    int? bpm;
    final hrResp =
        await YcProductPlugin().queryDeviceHealthData(HealthDataType.heartRate);
    if (hrResp != null && hrResp.statusCode == PluginState.succeed) {
      final rows = hrResp.data.whereType<HeartRateDataInfo>().toList();
      if (rows.isNotEmpty) {
        rows.sort((a, b) => b.startTimeStamp.compareTo(a.startTimeStamp));
        bpm = rows.first.heartRate;
      }
    }

    return CachedDeviceMetrics(
      batteryPercent: battery,
      sleepDuration: sleep?.duration,
      qualityLabel: sleep?.qualityLabel,
      insight: sleep?.insight,
      score: sleep?.score,
      heartRateBpm: bpm,
      syncedAt: DateTime.now(),
    );
  }

  static NightSleepSummary? _summarizeSleep(SleepDataInfo info) {
    final totalSec =
        info.deepSleepSeconds + info.lightSleepSeconds + info.remSleepSeconds;
    if (totalSec <= 0 && info.endTimeStamp > info.startTimeStamp) {
      final span = info.endTimeStamp - info.startTimeStamp;
      if (span <= 0) return null;
      return NightSleepSummary(
        duration: Duration(seconds: span),
        qualityLabel: '一般',
        insight: '已同步戒指睡眠时长',
        score: 70,
      );
    }
    if (totalSec <= 0) return null;

    final duration = Duration(seconds: totalSec);
    final deepRatio = info.deepSleepSeconds / totalSec;
    final hours = totalSec / 3600.0;
    String quality;
    int score;
    String insight;
    if (hours >= 7 && deepRatio >= 0.18) {
      quality = '良好';
      score = 82 + ((deepRatio - 0.18) * 40).round().clamp(0, 12);
      insight = '深睡偏充足，醒来精神更稳';
    } else if (hours < 5.5) {
      quality = '偏少';
      score = 55 + (hours * 4).round().clamp(0, 15);
      insight = '昨夜睡眠偏短，今晚可早点开始放松';
    } else {
      quality = '一般';
      score = 68 + (deepRatio * 40).round().clamp(0, 12);
      insight = '浅睡略多，可配合伴睡音帮助入睡';
    }
    return NightSleepSummary(
      duration: duration,
      qualityLabel: quality,
      insight: insight,
      score: score.clamp(40, 98),
    );
  }

  static String signalLabel(int rssi) {
    if (rssi >= -60) return '信号强 · 待连接';
    if (rssi >= -75) return '信号良好 · 待连接';
    if (rssi >= -85) return '信号一般 · 待连接';
    return '信号弱 · 待连接';
  }

  static ColorishSignal signalTone(int rssi) {
    if (rssi >= -75) return ColorishSignal.good;
    if (rssi >= -85) return ColorishSignal.medium;
    return ColorishSignal.weak;
  }
}

enum ColorishSignal { good, medium, weak }
