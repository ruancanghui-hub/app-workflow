import 'dart:convert';

import '../core/storage/key_value_store.dart';
import '../domain/models/heart_rate_series.dart';
import '../domain/models/sleep_day.dart';
import '../domain/repositories/health_data_repository.dart';
import '../domain/repositories/heart_rate_repository.dart';

class HeartRateRepositoryImpl implements HeartRateRepository {
  HeartRateRepositoryImpl({
    required KeyValueStore store,
    required HealthDataRepository health,
  })  : _store = store,
        _health = health;

  static const _meditationKey = 'meditation_playback_windows_v1';

  final KeyValueStore _store;
  final HealthDataRepository _health;

  @override
  Future<NightHeartRateSeries?> nightSeriesForSleepDay(
    DateTime sleepDayStart,
  ) async {
    final start = SleepDay.startOf(sleepDayStart);
    final night = await _health.nightSleep(start);
    if (night == null || night.stages.isEmpty) return null;
    final from = night.stages.first.start;
    final to = night.stages.last.end;
    final samples = await _health.heartRateSamples(from, to);
    if (samples.isEmpty) return null;
    return NightHeartRateSeries(
      sleepDayId: SleepDay.idOf(start),
      sleepDayStart: start,
      samples: samples,
    );
  }

  @override
  Future<List<NightHeartRateSeries>> recentNightSeries({
    int days = 7,
  }) async {
    final starts = SleepDay.recentStarts(DateTime.now(), count: days);
    final out = <NightHeartRateSeries>[];
    for (final day in starts.reversed) {
      final series = await nightSeriesForSleepDay(day);
      if (series != null && series.hasSamples) out.add(series);
    }
    return out;
  }

  @override
  Future<List<MeditationHeartRateRecord>> recentMeditationRecords({
    int days = 7,
  }) async {
    final all = await _readMeditation();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent =
        all.where((r) => r.startedAt.isAfter(cutoff)).toList(growable: false);
    final hydrated = <MeditationHeartRateRecord>[];
    for (final r in recent) {
      final samples =
          await _health.heartRateSamples(r.startedAt, r.endedAt);
      hydrated.add(r.copyWithSamples(samples));
    }
    return hydrated;
  }

  @override
  Future<MeditationHeartRateRecord?> meditationRecordById(String id) async {
    final all = await _readMeditation();
    for (final r in all) {
      if (r.id == id) {
        final samples =
            await _health.heartRateSamples(r.startedAt, r.endedAt);
        return r.copyWithSamples(samples);
      }
    }
    return null;
  }

  @override
  Future<void> saveMeditationRecord(MeditationHeartRateRecord record) async {
    if (!record.endedAt.isAfter(record.startedAt)) return;
    final all = await _readMeditation();
    all.removeWhere((r) => r.id == record.id);
    all.insert(
      0,
      MeditationHeartRateRecord(
        id: record.id,
        contentId: record.contentId,
        title: record.title,
        startedAt: record.startedAt,
        endedAt: record.endedAt,
      ),
    );
    // 保留近 60 条。
    final trimmed = all.take(60).toList();
    await _store.setString(
      _meditationKey,
      jsonEncode(trimmed.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<MeditationHeartRateRecord>> _readMeditation() async {
    final raw = await _store.getString(_meditationKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) =>
                MeditationHeartRateRecord.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
