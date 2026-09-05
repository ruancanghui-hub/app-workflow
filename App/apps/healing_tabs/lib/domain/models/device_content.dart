/// 戒指（设备）领域模型：连接态与体征摘要，不含 UI。
enum DeviceConnectionState { unpaired, connecting, connected, syncing }

class RingDevice {
  const RingDevice({
    required this.id,
    required this.displayName,
    required this.connectionState,
    required this.batteryPercent,
  });

  final String id;
  final String displayName;
  final DeviceConnectionState connectionState;
  final int batteryPercent;

  /// 已绑定（含重连中），与「未配对」相对。
  bool get isPaired =>
      connectionState != DeviceConnectionState.unpaired;
}

/// 昨夜睡眠摘要（戒指监测），详情见睡眠报告。
class NightSleepSummary {
  const NightSleepSummary({
    required this.duration,
    required this.qualityLabel,
    required this.insight,
    required this.score,
  });

  final Duration duration;
  final String qualityLabel;
  final String insight;
  final int score;
}

/// 心率读数（V1：静息或实时其一）。
class HeartRateReading {
  const HeartRateReading({
    required this.bpm,
    required this.kindLabel,
    required this.baselineHint,
  });

  final int bpm;
  final String kindLabel;
  final String baselineHint;
}

class DeviceDaySnapshot {
  const DeviceDaySnapshot({
    required this.device,
    required this.headline,
    this.sleep,
    this.heartRate,
  });

  final RingDevice device;
  final String headline;
  final NightSleepSummary? sleep;
  final HeartRateReading? heartRate;
}

enum DeviceContentActionKind { sleep, meditation }

class DeviceContentAction {
  const DeviceContentAction({
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String title;
  final String subtitle;
  final DeviceContentActionKind kind;
}
