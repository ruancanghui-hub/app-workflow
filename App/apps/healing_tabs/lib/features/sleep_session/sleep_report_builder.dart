import '../../domain/models/health_vitals.dart';
import '../../domain/models/sleep_session.dart';

/// 将健康数据整理为报告字段；**不合成**阶段图 / 演示分 / 优劣标签。
abstract final class SleepReportBuilder {
  /// 仅规范化结束时间；保留会话上已有真实字段，不填充演示数据。
  static SleepSession enrich(SleepSession session) {
    final endedAt = session.endedAt ?? DateTime.now();
    final effectiveEnd = endedAt.isAfter(session.startedAt)
        ? endedAt
        : session.startedAt.add(const Duration(minutes: 1));
    return session.copyWith(endedAt: effectiveEnd);
  }

  /// 由 Apple 健康夜间睡眠构造报告会话。
  static SleepSession fromHealth(NightSleepData night) {
    DateTime start;
    DateTime end;
    if (night.stages.isNotEmpty) {
      start = night.stages.first.start;
      end = night.stages.last.end;
      if (!end.isAfter(start)) {
        end = start.add(night.duration);
      }
    } else {
      end = night.sleepDayStart.add(const Duration(hours: 19));
      start = end.subtract(night.duration);
    }
    return SleepSession(
      id: 'health-${night.sleepDayStart.millisecondsSinceEpoch}',
      startedAt: start,
      endedAt: end,
      status: SleepSessionStatus.completed,
      qualityLabel: null,
      insight: night.insight ?? '来自 Apple 健康',
      score: null,
      stages: night.hasStages ? night.stages : null,
    );
  }
}
