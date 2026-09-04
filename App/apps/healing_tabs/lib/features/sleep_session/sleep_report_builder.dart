import '../../domain/models/device_content.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/models/sleep_stage_segment.dart';
import '../tabs/device/device_content_catalog.dart';

/// Builds ring-backed report fields for a completed sleep session (V1 demo data).
abstract final class SleepReportBuilder {
  static SleepSession enrich(SleepSession session) {
    final endedAt = session.endedAt ?? DateTime.now();
    final effectiveEnd = endedAt.isAfter(session.startedAt)
        ? endedAt
        : session.startedAt.add(const Duration(minutes: 1));
    final summary = DeviceContentCatalog.pairedSnapshot.sleep;
    return session.copyWith(
      endedAt: effectiveEnd,
      qualityLabel: session.qualityLabel ?? summary?.qualityLabel,
      insight: session.insight ?? summary?.insight,
      score: session.score ?? summary?.score,
      stages: (session.stages == null || session.stages!.isEmpty)
          ? generateStages(session.startedAt, effectiveEnd)
          : session.stages,
    );
  }

  static SleepSession fromSummary(NightSleepSummary summary) {
    final now = DateTime.now();
    final wake = DateTime(now.year, now.month, now.day, 7, 12);
    final start = wake.subtract(summary.duration);
    return enrich(
      SleepSession(
        id: 'ring-${start.millisecondsSinceEpoch}',
        startedAt: start,
        endedAt: wake,
        status: SleepSessionStatus.completed,
        qualityLabel: summary.qualityLabel,
        insight: summary.insight,
        score: summary.score,
      ),
    );
  }

  static List<SleepStageSegment> generateStages(DateTime start, DateTime end) {
    final pattern = <SleepStageKind>[
      SleepStageKind.light,
      SleepStageKind.deep,
      SleepStageKind.light,
      SleepStageKind.rem,
      SleepStageKind.light,
      SleepStageKind.deep,
      SleepStageKind.awake,
      SleepStageKind.light,
      SleepStageKind.rem,
      SleepStageKind.deep,
      SleepStageKind.light,
    ];
    final totalMs = end.difference(start).inMilliseconds;
    if (totalMs <= 0) {
      return [
        SleepStageSegment(
          start: start,
          end: start.add(const Duration(minutes: 1)),
          kind: SleepStageKind.light,
        ),
      ];
    }

    final segmentLengthMs = totalMs ~/ pattern.length;
    final segments = <SleepStageSegment>[];
    var cursor = start;
    for (var i = 0; i < pattern.length; i++) {
      final isLast = i == pattern.length - 1;
      final next = isLast
          ? end
          : cursor.add(Duration(milliseconds: segmentLengthMs));
      if (next.isAfter(cursor)) {
        segments.add(
          SleepStageSegment(start: cursor, end: next, kind: pattern[i]),
        );
      }
      cursor = next;
    }
    if (segments.isEmpty) {
      segments.add(
        SleepStageSegment(start: start, end: end, kind: SleepStageKind.light),
      );
    }
    return segments;
  }
}
