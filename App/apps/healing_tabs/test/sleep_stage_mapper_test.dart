import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/data/health/sleep_stage_mapper.dart';
import 'package:healing_tabs/domain/models/sleep_day.dart';
import 'package:healing_tabs/domain/models/sleep_stage_segment.dart';

void main() {
  group('SleepStageMapper', () {
    test('maps HealthKit type names', () {
      expect(SleepStageMapper.kindForTypeName('SLEEP_DEEP'), SleepStageKind.deep);
      expect(SleepStageMapper.kindForTypeName('SLEEP_LIGHT'), SleepStageKind.light);
      expect(SleepStageMapper.kindForTypeName('SLEEP_ASLEEP'), SleepStageKind.light);
      expect(SleepStageMapper.kindForTypeName('SLEEP_REM'), SleepStageKind.rem);
      expect(SleepStageMapper.kindForTypeName('SLEEP_AWAKE'), SleepStageKind.awake);
      expect(SleepStageMapper.kindForTypeName('SLEEP_IN_BED'), isNull);
    });

    test('aggregates stages into sleep day window', () {
      final day = SleepDay.startOf(DateTime(2026, 11, 10, 15));
      final stages = [
        SleepStageSegment(
          start: day.add(const Duration(hours: 10)),
          end: day.add(const Duration(hours: 11)),
          kind: SleepStageKind.deep,
        ),
        SleepStageSegment(
          start: day.add(const Duration(hours: 11)),
          end: day.add(const Duration(hours: 13)),
          kind: SleepStageKind.light,
        ),
        // Outside window — ignored
        SleepStageSegment(
          start: day.add(const Duration(days: 2)),
          end: day.add(const Duration(days: 2, hours: 1)),
          kind: SleepStageKind.rem,
        ),
      ];
      final night = SleepStageMapper.buildNight(
        sleepDayStart: day,
        stages: stages,
      );
      expect(night, isNotNull);
      expect(night!.duration, const Duration(hours: 3));
      expect(night.stages.length, 2);
      expect(night.insight, contains('深睡'));
    });
  });
}
