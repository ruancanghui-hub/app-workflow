import 'dart:convert';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/heart_rate_series.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/repositories/heart_rate_repository.dart';

class HeartRateRepositoryImpl implements HeartRateRepository {
  HeartRateRepositoryImpl(this._store);

  static const _meditationKey = 'meditation_hr_records_v1';
  static const _nightKey = 'night_hr_series_v1';

  final KeyValueStore _store;

  @override
  Future<NightHeartRateSeries?> nightSeriesForSleepDay(
    DateTime sleepDayStart,
  ) async {
    final id = SleepDay.idOf(sleepDayStart);
    final all = await _readNight();
    for (final s in all) {
      if (s.sleepDayId == id && s.hasSamples) return s;
    }
    return null;
  }

  @override
  Future<List<NightHeartRateSeries>> recentNightSeries({
    int days = 7,
  }) async {
    final starts = SleepDay.recentStarts(DateTime.now(), count: days);
    final ids = starts.map(SleepDay.idOf).toSet();
    final all = await _readNight();
    final matched = all
        .where((s) => ids.contains(s.sleepDayId) && s.hasSamples)
        .toList()
      ..sort((a, b) => b.sleepDayStart.compareTo(a.sleepDayStart));
    return matched;
  }

  @override
  Future<void> appendNightSamples(
    DateTime sleepDayStart,
    List<HeartRateSample> samples,
  ) async {
    if (samples.isEmpty) return;
    final id = SleepDay.idOf(sleepDayStart);
    final start = SleepDay.startOf(sleepDayStart);
    final all = await _readNight();
    final idx = all.indexWhere((s) => s.sleepDayId == id);
    final existing = idx >= 0 ? all[idx].samples : <HeartRateSample>[];
    final merged = [...existing, ...samples]
      ..sort((a, b) => a.at.compareTo(b.at));
    // 去重：同一秒同一 bpm 只留一条
    final deduped = <HeartRateSample>[];
    for (final s in merged) {
      if (deduped.isEmpty ||
          deduped.last.at != s.at ||
          deduped.last.bpm != s.bpm) {
        deduped.add(s);
      }
    }
    final series = NightHeartRateSeries(
      sleepDayId: id,
      sleepDayStart: start,
      samples: deduped,
    );
    if (idx >= 0) {
      all[idx] = series;
    } else {
      all.insert(0, series);
    }
    await _store.setString(
      _nightKey,
      jsonEncode(all.map(_nightToJson).toList()),
    );
  }

  @override
  Future<List<MeditationHeartRateRecord>> recentMeditationRecords({
    int days = 7,
  }) async {
    final all = await _readMeditation();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return all.where((r) => r.startedAt.isAfter(cutoff)).toList();
  }

  @override
  Future<MeditationHeartRateRecord?> meditationRecordById(String id) async {
    final all = await _readMeditation();
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<void> saveMeditationRecord(MeditationHeartRateRecord record) async {
    if (!record.hasSamples) return;
    final all = await _readMeditation();
    all.removeWhere((r) => r.id == record.id);
    all.insert(0, record);
    await _store.setString(
      _meditationKey,
      jsonEncode(all.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<MeditationHeartRateRecord>> _readMeditation() async {
    final raw = await _store.getString(_meditationKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (e) => MeditationHeartRateRecord.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<NightHeartRateSeries>> _readNight() async {
    final raw = await _store.getString(_nightKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _nightFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _nightToJson(NightHeartRateSeries s) => {
        'sleepDayId': s.sleepDayId,
        'sleepDayStart': s.sleepDayStart.toIso8601String(),
        'samples': s.samples.map((x) => x.toJson()).toList(),
      };

  static NightHeartRateSeries _nightFromJson(Map<String, dynamic> json) =>
      NightHeartRateSeries(
        sleepDayId: json['sleepDayId'] as String,
        sleepDayStart: DateTime.parse(json['sleepDayStart'] as String),
        samples: (json['samples'] as List<dynamic>)
            .map((e) => HeartRateSample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
