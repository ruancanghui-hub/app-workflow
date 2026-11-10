import '../models/heart_rate_series.dart';

/// 心率时序仓储：夜间曲线与冥想播放记录。
/// 本地只存播放时间窗；曲线在查看时从 HealthKit 查询。禁止合成曲线。
abstract class HeartRateRepository {
  Future<NightHeartRateSeries?> nightSeriesForSleepDay(DateTime sleepDayStart);

  /// 近 [days] 天内有样本的夜间曲线（按睡眠日倒序）。
  Future<List<NightHeartRateSeries>> recentNightSeries({int days = 7});

  Future<List<MeditationHeartRateRecord>> recentMeditationRecords({
    int days = 7,
  });

  Future<MeditationHeartRateRecord?> meditationRecordById(String id);

  /// 保存播放时间窗（不含心率样本）。
  Future<void> saveMeditationRecord(MeditationHeartRateRecord record);
}
