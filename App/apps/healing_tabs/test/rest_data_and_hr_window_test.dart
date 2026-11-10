import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/data/device_repository_impl.dart';
import 'package:healing_tabs/data/health/playback_window_recorder.dart';
import 'package:healing_tabs/data/heart_rate_repository_impl.dart';
import 'package:healing_tabs/domain/models/health_vitals.dart';
import 'package:healing_tabs/domain/models/heart_rate_series.dart';
import 'package:healing_tabs/domain/models/sleep_day.dart';
import 'package:healing_tabs/domain/models/sleep_stage_segment.dart';
import 'package:healing_tabs/domain/repositories/health_data_repository.dart';
import 'package:healing_tabs/features/device/rest_data_controller.dart';
import 'package:healing_tabs/features/sleep_session/sleep_report_builder.dart';

class _FakeHealth implements HealthDataRepository {
  _FakeHealth({
    this.requested = false,
    this.resting,
    this.latest,
    this.samples = const [],
  });

  bool requested;
  NightSleepData? sleep;
  HeartRatePoint? resting;
  HeartRatePoint? latest;
  List<HeartRateSample> samples;

  @override
  bool get isSupported => true;

  @override
  Future<bool> hasRequestedAuthorization() async => requested;

  @override
  Future<bool> requestAuthorization() async {
    requested = true;
    return true;
  }

  @override
  Future<NightSleepData?> nightSleep(DateTime sleepDayStart) async => sleep;

  @override
  Future<List<NightSleepData>> recentNightSleep({int days = 7}) async =>
      sleep == null ? const [] : [sleep!];

  @override
  Future<HeartRatePoint?> restingHeartRate(DateTime day) async => resting;

  @override
  Future<HeartRatePoint?> latestHeartRate() async => latest;

  @override
  Future<List<HeartRateSample>> heartRateSamples(
    DateTime start,
    DateTime end,
  ) async =>
      samples;
}

void main() {
  test('RestDataController auth states', () async {
    final store = FakeKeyValueStore();
    final device = DeviceRepositoryImpl(store);
    final health = _FakeHealth();
    final controller = RestDataController(
      deviceRepository: device,
      health: health,
    );
    await controller.refreshSnapshot();
    expect(controller.authState.value, HealthAuthState.disconnected);

    health.requested = true;
    await controller.refreshSnapshot();
    expect(controller.authState.value, HealthAuthState.connectedNoData);

    final day = SleepDay.startOf(DateTime.now());
    health.sleep = NightSleepData(
      sleepDayStart: day,
      duration: const Duration(hours: 7),
      stages: [
        SleepStageSegment(
          start: day.add(const Duration(hours: 10)),
          end: day.add(const Duration(hours: 17)),
          kind: SleepStageKind.light,
        ),
      ],
      insight: '浅睡约 7 小时 0 分',
    );
    health.resting = HeartRatePoint(
      bpm: 58,
      at: DateTime.now(),
      isResting: true,
    );
    await controller.refreshSnapshot();
    expect(controller.authState.value, HealthAuthState.connectedWithData);
    expect(controller.snapshot.value.heartRate?.bpm, 58);
    controller.onClose();
  });

  test('heart rate prefers resting over latest', () async {
    final store = FakeKeyValueStore();
    final health = _FakeHealth(
      requested: true,
      resting: HeartRatePoint(
        bpm: 55,
        at: DateTime.now(),
        isResting: true,
      ),
      latest: HeartRatePoint(
        bpm: 90,
        at: DateTime.now(),
        isResting: false,
      ),
    );
    final controller = RestDataController(
      deviceRepository: DeviceRepositoryImpl(store),
      health: health,
    );
    await controller.refreshSnapshot();
    expect(controller.snapshot.value.heartRate?.bpm, 55);
    expect(controller.snapshot.value.heartRate?.isResting, isTrue);
    controller.onClose();
  });

  test('playback window hydrates samples on view', () async {
    final store = FakeKeyValueStore();
    final health = _FakeHealth(
      requested: true,
      samples: [
        HeartRateSample(at: DateTime(2026, 11, 10, 9, 1), bpm: 70),
        HeartRateSample(at: DateTime(2026, 11, 10, 9, 3), bpm: 72),
      ],
    );
    final hrRepo = HeartRateRepositoryImpl(store: store, health: health);
    final recorder = PlaybackWindowRecorder(heartRateRepository: hrRepo);
    await recorder.begin(contentId: 'c1', title: '测试冥想');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await recorder.end();

    final recent = await hrRepo.recentMeditationRecords(days: 7);
    expect(recent, isNotEmpty);
    expect(recent.first.hasSamples, isTrue);
    expect(recent.first.samples.length, 2);
  });

  test('SleepReportBuilder.fromHealth drops score labels', () {
    final day = SleepDay.startOf(DateTime(2026, 11, 10, 15));
    final night = NightSleepData(
      sleepDayStart: day,
      duration: const Duration(hours: 6, minutes: 30),
      stages: [
        SleepStageSegment(
          start: day.add(const Duration(hours: 10)),
          end: day.add(const Duration(hours: 12)),
          kind: SleepStageKind.deep,
        ),
      ],
      insight: '深睡约 2 小时 0 分',
    );
    final session = SleepReportBuilder.fromHealth(night);
    expect(session.score, isNull);
    expect(session.qualityLabel, isNull);
    expect(session.stages, isNotEmpty);
    expect(session.insight, contains('深睡'));
  });

  test('ring migration wipes legacy keys once', () async {
    final store = FakeKeyValueStore();
    await store.setString('device_paired_v1', 'true');
    await store.setString('night_hr_series_v1', '[]');
    final repo = DeviceRepositoryImpl(store);
    await repo.migrateFromRingIfNeeded();
    expect(await store.getString('device_paired_v1'), isNull);
    expect(await store.getString('night_hr_series_v1'), isNull);
    await store.setString('device_paired_v1', 'again');
    await repo.migrateFromRingIfNeeded();
    expect(await store.getString('device_paired_v1'), 'again');
  });
}
