import '../models/health_vitals.dart';
import '../models/heart_rate_series.dart';

/// Apple 健康（或其他平台健康库）只读体征数据。
abstract class HealthDataRepository {
  bool get isSupported;

  Future<bool> hasRequestedAuthorization();

  /// 请求读权限；成功弹过后本地标记已请求。返回值不代表用户是否同意。
  Future<bool> requestAuthorization();

  /// 某一睡眠日的夜间睡眠（阶段 + 总时长）。无数据返回 null。
  Future<NightSleepData?> nightSleep(DateTime sleepDayStart);

  /// 近 [days] 个睡眠日的夜间睡眠（有数据的才返回，按日倒序）。
  Future<List<NightSleepData>> recentNightSleep({int days = 7});

  /// 指定自然日的静息心率；无则 null。
  Future<HeartRatePoint?> restingHeartRate(DateTime day);

  /// 最近一次心率样本。
  Future<HeartRatePoint?> latestHeartRate();

  /// [start, end] 区间内心率样本（升序）。
  Future<List<HeartRateSample>> heartRateSamples(
    DateTime start,
    DateTime end,
  );
}
