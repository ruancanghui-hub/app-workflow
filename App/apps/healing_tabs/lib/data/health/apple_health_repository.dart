import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/health_vitals.dart';
import '../../domain/models/heart_rate_series.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/models/sleep_stage_segment.dart';
import '../../domain/repositories/health_data_repository.dart';
import 'sleep_stage_mapper.dart';

/// iOS HealthKit 只读实现。
class AppleHealthRepository implements HealthDataRepository {
  AppleHealthRepository(this._store, {Health? health})
      : _health = health ?? Health();

  static const authRequestedKey = 'health_auth_requested_v1';

  static const _sleepTypes = <HealthDataType>[
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
  ];

  static const _readTypes = <HealthDataType>[
    ..._sleepTypes,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
  ];

  final KeyValueStore _store;
  final Health _health;
  var _configured = false;

  @override
  bool get isSupported => true;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> hasRequestedAuthorization() async {
    final raw = await _store.getString(authRequestedKey);
    return raw == 'true';
  }

  @override
  Future<bool> requestAuthorization() async {
    try {
      await _ensureConfigured();
      final ok = await _health.requestAuthorization(_readTypes);
      await _store.setString(authRequestedKey, 'true');
      return ok;
    } catch (e, st) {
      debugPrint('[Health] requestAuthorization failed: $e\n$st');
      await _store.setString(authRequestedKey, 'true');
      return false;
    }
  }

  @override
  Future<NightSleepData?> nightSleep(DateTime sleepDayStart) async {
    final start = SleepDay.startOf(sleepDayStart);
    final end = start.add(const Duration(days: 1));
    final stages = await _fetchStages(start, end);
    return SleepStageMapper.buildNight(
      sleepDayStart: start,
      stages: stages,
    );
  }

  @override
  Future<List<NightSleepData>> recentNightSleep({int days = 7}) async {
    final starts = SleepDay.recentStarts(DateTime.now(), count: days);
    final rangeStart = starts.first;
    final rangeEnd = starts.last.add(const Duration(days: 1));
    final stages = await _fetchStages(rangeStart, rangeEnd);
    final results = <NightSleepData>[];
    for (final day in starts.reversed) {
      final night = SleepStageMapper.buildNight(
        sleepDayStart: day,
        stages: stages,
      );
      if (night != null) results.add(night);
    }
    return results;
  }

  @override
  Future<HeartRatePoint?> restingHeartRate(DateTime day) async {
    final local = day.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    final end = start.add(const Duration(days: 1));
    final points = await _fetchNumeric(
      HealthDataType.RESTING_HEART_RATE,
      start,
      end,
    );
    if (points.isEmpty) return null;
    points.sort((a, b) => b.at.compareTo(a.at));
    return HeartRatePoint(
      bpm: points.first.bpm,
      at: points.first.at,
      isResting: true,
    );
  }

  @override
  Future<HeartRatePoint?> latestHeartRate() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 2));
    final points = await _fetchNumeric(HealthDataType.HEART_RATE, start, end);
    if (points.isEmpty) return null;
    points.sort((a, b) => b.at.compareTo(a.at));
    return HeartRatePoint(
      bpm: points.first.bpm,
      at: points.first.at,
      isResting: false,
    );
  }

  @override
  Future<List<HeartRateSample>> heartRateSamples(
    DateTime start,
    DateTime end,
  ) async {
    if (!end.isAfter(start)) return const [];
    final points = await _fetchNumeric(HealthDataType.HEART_RATE, start, end);
    points.sort((a, b) => a.at.compareTo(b.at));
    return points
        .map((p) => HeartRateSample(at: p.at, bpm: p.bpm))
        .toList(growable: false);
  }

  Future<List<SleepStageSegment>> _fetchStages(
    DateTime start,
    DateTime end,
  ) async {
    if (!await hasRequestedAuthorization()) return const [];
    try {
      await _ensureConfigured();
      final raw = await _health.getHealthDataFromTypes(
        types: _sleepTypes,
        startTime: start,
        endTime: end,
      );
      final stages = <SleepStageSegment>[];
      for (final p in raw) {
        final kind = SleepStageMapper.kindForTypeName(p.type.name);
        if (kind == null) continue;
        if (!p.dateTo.isAfter(p.dateFrom)) continue;
        stages.add(
          SleepStageSegment(
            start: p.dateFrom.toLocal(),
            end: p.dateTo.toLocal(),
            kind: kind,
          ),
        );
      }
      stages.sort((a, b) => a.start.compareTo(b.start));
      return stages;
    } catch (e, st) {
      debugPrint('[Health] fetchStages failed: $e\n$st');
      return const [];
    }
  }

  Future<List<({DateTime at, int bpm})>> _fetchNumeric(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    if (!await hasRequestedAuthorization()) return [];
    try {
      await _ensureConfigured();
      final raw = await _health.getHealthDataFromTypes(
        types: [type],
        startTime: start,
        endTime: end,
      );
      final out = <({DateTime at, int bpm})>[];
      for (final p in raw) {
        final v = p.value;
        double? numeric;
        if (v is NumericHealthValue) {
          numeric = v.numericValue.toDouble();
        }
        if (numeric == null || numeric <= 0) continue;
        out.add((at: p.dateFrom.toLocal(), bpm: numeric.round()));
      }
      return out;
    } catch (e, st) {
      debugPrint('[Health] fetchNumeric $type failed: $e\n$st');
      return [];
    }
  }
}
