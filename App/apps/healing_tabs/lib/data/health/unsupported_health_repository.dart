import '../../domain/models/health_vitals.dart';
import '../../domain/models/heart_rate_series.dart';
import '../../domain/repositories/health_data_repository.dart';

/// Android 等非 HealthKit 平台：全部空实现。
class UnsupportedHealthRepository implements HealthDataRepository {
  @override
  bool get isSupported => false;

  @override
  Future<bool> hasRequestedAuthorization() async => false;

  @override
  Future<bool> requestAuthorization() async => false;

  @override
  Future<NightSleepData?> nightSleep(DateTime sleepDayStart) async => null;

  @override
  Future<List<NightSleepData>> recentNightSleep({int days = 7}) async =>
      const [];

  @override
  Future<HeartRatePoint?> restingHeartRate(DateTime day) async => null;

  @override
  Future<HeartRatePoint?> latestHeartRate() async => null;

  @override
  Future<List<HeartRateSample>> heartRateSamples(
    DateTime start,
    DateTime end,
  ) async =>
      const [];
}
