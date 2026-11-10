import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../domain/models/health_vitals.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/health_data_repository.dart';
import '../tabs/device/device_content_catalog.dart';

/// 休息 Tab：健康授权态 + 昨夜摘要 + 心率读数。
class RestDataController extends GetxController {
  RestDataController({
    required DeviceRepository deviceRepository,
    required HealthDataRepository health,
  })  : _deviceRepository = deviceRepository,
        _health = health;

  final DeviceRepository _deviceRepository;
  final HealthDataRepository _health;

  final authState = HealthAuthState.disconnected.obs;
  final syncing = false.obs;
  final snapshot = DeviceContentCatalog.disconnectedSnapshot.obs;
  final statusMessage = ''.obs;

  bool get isConnected => authState.value != HealthAuthState.disconnected;

  bool get hasRequested => isConnected;

  @override
  void onInit() {
    super.onInit();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await _deviceRepository.migrateFromRingIfNeeded();
    } catch (e, st) {
      debugPrint('ring migration failed: $e\n$st');
    }
    await refreshSnapshot();
  }

  Future<void> refreshSnapshot() async {
    if (!_health.isSupported) {
      authState.value = HealthAuthState.disconnected;
      snapshot.value = DeviceContentCatalog.disconnectedSnapshot;
      return;
    }
    final requested = await _health.hasRequestedAuthorization();
    if (!requested) {
      authState.value = HealthAuthState.disconnected;
      snapshot.value = DeviceContentCatalog.disconnectedSnapshot;
      return;
    }
    syncing.value = true;
    statusMessage.value = '';
    try {
      final sleepDay = SleepDay.startOf(DateTime.now());
      final sleep = await _health.nightSleep(sleepDay);
      final heart = await _resolveHeartReading();
      final hasData = sleep != null || heart != null;
      authState.value = hasData
          ? HealthAuthState.connectedWithData
          : HealthAuthState.connectedNoData;
      snapshot.value = _buildSnapshot(
        state: authState.value,
        sleep: sleep,
        heart: heart,
      );
    } catch (e, st) {
      debugPrint('RestDataController.refresh failed: $e\n$st');
      authState.value = HealthAuthState.connectedNoData;
      snapshot.value = DeviceContentCatalog.connectedNoDataSnapshot;
    } finally {
      syncing.value = false;
    }
  }

  Future<bool> connectAppleHealth() async {
    if (!_health.isSupported) {
      statusMessage.value = '当前平台不支持 Apple 健康';
      return false;
    }
    statusMessage.value = '正在连接…';
    try {
      await _health.requestAuthorization();
      await _deviceRepository.setHealthAuthorizationRequested(true);
      await refreshSnapshot();
      statusMessage.value = '';
      return isConnected;
    } catch (e, st) {
      debugPrint('connectAppleHealth failed: $e\n$st');
      statusMessage.value = '连接失败，请重试';
      return false;
    }
  }

  Future<HeartRatePoint?> _resolveHeartReading() async {
    final today = DateTime.now();
    final resting = await _health.restingHeartRate(today);
    if (resting != null) return resting;
    return _health.latestHeartRate();
  }

  static RestDaySnapshot _buildSnapshot({
    required HealthAuthState state,
    NightSleepData? sleep,
    HeartRatePoint? heart,
  }) {
    if (state == HealthAuthState.disconnected) {
      return DeviceContentCatalog.disconnectedSnapshot;
    }
    if (sleep == null && heart == null) {
      return DeviceContentCatalog.connectedNoDataSnapshot;
    }
    final parts = <String>[];
    if (sleep != null) {
      parts.add('昨夜休息 ${_fmtDuration(sleep.duration)}');
    }
    if (heart != null) {
      parts.add(
        heart.isResting
            ? '静息心率 ${heart.bpm}'
            : '心率 ${heart.bpm}',
      );
    }
    return RestDaySnapshot(
      authState: HealthAuthState.connectedWithData,
      headline: parts.join(' · '),
      sleep: sleep,
      heartRate: heart,
    );
  }

  static String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h 小时 $m 分';
    return '$m 分';
  }
}
