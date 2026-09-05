import 'dart:convert';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/heart_rate_series.dart';
import '../../domain/repositories/heart_rate_repository.dart';

class HeartRateRepositoryImpl implements HeartRateRepository {
  HeartRateRepositoryImpl(this._store);

  static const _meditationKey = 'meditation_hr_records_v1';

  final KeyValueStore _store;

  @override
  Future<NightHeartRateSeries?> nightSeriesForSleepDay(
    DateTime sleepDayStart,
  ) async {
    // BLE 整夜时序管道后置：当前无真数据则空。
    return null;
  }

  @override
  Future<List<NightHeartRateSeries>> recentNightSeries({
    int days = 7,
  }) async {
    return const [];
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
}
