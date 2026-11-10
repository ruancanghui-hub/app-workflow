import 'heart_rate_series.dart';
import 'sleep_stage_segment.dart';

/// 健康授权态（Apple 健康读权限视角）。
enum HealthAuthState {
  /// 尚未请求授权，或平台不支持。
  disconnected,

  /// 已请求过授权，且有可读的睡眠/心率数据。
  connectedWithData,

  /// 已请求过授权，但暂无可读数据（可能被拒或尚未同步）。
  connectedNoData,
}

/// 某一睡眠日的夜间睡眠（来自 Apple 健康）。
class NightSleepData {
  const NightSleepData({
    required this.sleepDayStart,
    required this.duration,
    required this.stages,
    this.insight,
  });

  final DateTime sleepDayStart;
  final Duration duration;
  final List<SleepStageSegment> stages;
  final String? insight;

  bool get hasStages => stages.isNotEmpty;
}

/// 单点心率读数（静息或最近一次）。
class HeartRatePoint {
  const HeartRatePoint({
    required this.bpm,
    required this.at,
    required this.isResting,
  });

  final int bpm;
  final DateTime at;
  final bool isResting;
}

/// 休息 Tab 日摘要。
class RestDaySnapshot {
  const RestDaySnapshot({
    required this.authState,
    required this.headline,
    this.sleep,
    this.heartRate,
  });

  final HealthAuthState authState;
  final String headline;
  final NightSleepData? sleep;
  final HeartRatePoint? heartRate;

  bool get isConnected => authState != HealthAuthState.disconnected;

  bool get hasVitals => sleep != null || heartRate != null;
}

/// 便于曲线拼装：时间窗 + 样本。
class HeartRateWindowSeries {
  const HeartRateWindowSeries({
    required this.startedAt,
    required this.endedAt,
    required this.samples,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final List<HeartRateSample> samples;

  bool get hasSamples => samples.isNotEmpty;
}
