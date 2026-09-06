import '../../domain/models/device_content.dart';
import '../../domain/models/sleep_session.dart';

/// 将监测会话整理为报告字段；**不合成**阶段图 / 演示分 / 洞察。
abstract final class SleepReportBuilder {
  /// 仅规范化结束时间；保留会话上已有真实字段，不填充演示数据。
  static SleepSession enrich(SleepSession session) {
    final endedAt = session.endedAt ?? DateTime.now();
    final effectiveEnd = endedAt.isAfter(session.startedAt)
        ? endedAt
        : session.startedAt.add(const Duration(minutes: 1));
    return session.copyWith(endedAt: effectiveEnd);
  }

  /// 由戒指摘要构造报告会话：时长与摘要文案来自设备，不含合成阶段。
  static SleepSession fromSummary(NightSleepSummary summary) {
    final now = DateTime.now();
    final wake = DateTime(now.year, now.month, now.day, 7, 0);
    final start = wake.subtract(summary.duration);
    return SleepSession(
      id: 'ring-${start.millisecondsSinceEpoch}',
      startedAt: start,
      endedAt: wake,
      status: SleepSessionStatus.completed,
      qualityLabel: summary.qualityLabel,
      insight: summary.insight,
      score: summary.score,
      stages: null,
    );
  }
}
