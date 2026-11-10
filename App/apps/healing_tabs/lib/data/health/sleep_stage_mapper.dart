import '../../domain/models/health_vitals.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/models/sleep_stage_segment.dart';

/// HealthKit 睡眠类型 → 领域阶段，以及睡眠日聚合。
abstract final class SleepStageMapper {
  /// 核心睡眠 / asleep / light → 浅睡；deep / rem / awake 各自对应。
  /// in_bed / session / unknown / out_of_bed 不计入阶段图。
  static SleepStageKind? kindForTypeName(String typeName) {
    switch (typeName) {
      case 'SLEEP_DEEP':
        return SleepStageKind.deep;
      case 'SLEEP_LIGHT':
      case 'SLEEP_ASLEEP':
        return SleepStageKind.light;
      case 'SLEEP_REM':
        return SleepStageKind.rem;
      case 'SLEEP_AWAKE':
      case 'SLEEP_AWAKE_IN_BED':
        return SleepStageKind.awake;
      default:
        return null;
    }
  }

  static String neutralInsight(List<SleepStageSegment> stages) {
    if (stages.isEmpty) return '来自 Apple 健康';
    var deep = Duration.zero;
    var light = Duration.zero;
    var rem = Duration.zero;
    var awake = Duration.zero;
    for (final s in stages) {
      final d = s.end.difference(s.start);
      switch (s.kind) {
        case SleepStageKind.deep:
          deep += d;
        case SleepStageKind.light:
          light += d;
        case SleepStageKind.rem:
          rem += d;
        case SleepStageKind.awake:
          awake += d;
      }
    }
    final parts = <String>[];
    if (deep > Duration.zero) parts.add('深睡约 ${_fmt(deep)}');
    if (light > Duration.zero) parts.add('浅睡约 ${_fmt(light)}');
    if (rem > Duration.zero) parts.add('REM 约 ${_fmt(rem)}');
    if (awake > Duration.zero) parts.add('清醒约 ${_fmt(awake)}');
    if (parts.isEmpty) return '来自 Apple 健康';
    return parts.take(2).join(' · ');
  }

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h 小时 $m 分';
    return '$m 分';
  }

  /// 将阶段段按睡眠日切点聚合为 [NightSleepData]。
  static NightSleepData? buildNight({
    required DateTime sleepDayStart,
    required List<SleepStageSegment> stages,
  }) {
    final dayEnd = sleepDayStart.add(const Duration(days: 1));
    final inWindow = stages.where((s) {
      final anchor = s.start;
      return !anchor.isBefore(sleepDayStart) && anchor.isBefore(dayEnd);
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (inWindow.isEmpty) return null;

    var asleep = Duration.zero;
    for (final s in inWindow) {
      if (s.kind == SleepStageKind.awake) continue;
      asleep += s.end.difference(s.start);
    }
    if (asleep <= Duration.zero) {
      // 仅有清醒段时仍返回，时长取跨度。
      asleep = inWindow.last.end.difference(inWindow.first.start);
    }

    return NightSleepData(
      sleepDayStart: SleepDay.startOf(sleepDayStart),
      duration: asleep,
      stages: inWindow,
      insight: neutralInsight(inWindow),
    );
  }
}
