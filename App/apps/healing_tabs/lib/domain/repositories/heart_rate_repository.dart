import '../models/heart_rate_series.dart';

/// 心率时序仓储：夜间曲线与冥想播放期记录。
/// 无真时序时返回空；禁止用合成曲线冒充监测。
abstract class HeartRateRepository {
  Future<NightHeartRateSeries?> nightSeriesForSleepDay(DateTime sleepDayStart);

  /// 近 [days] 天内有采样的夜间曲线（按睡眠日倒序）。
  Future<List<NightHeartRateSeries>> recentNightSeries({int days = 7});

  Future<List<MeditationHeartRateRecord>> recentMeditationRecords({
    int days = 7,
  });

  Future<MeditationHeartRateRecord?> meditationRecordById(String id);

  Future<void> saveMeditationRecord(MeditationHeartRateRecord record);
}
