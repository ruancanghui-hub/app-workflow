import '../../../domain/models/device_content.dart';

/// 戒指 Tab 演示快照与体征推荐（无真实蓝牙，仅占位数据）。
abstract final class DeviceContentCatalog {
  static const pairedDevice = RingDevice(
    id: 'ring-demo-1',
    displayName: '云遥戒指',
    connectionState: DeviceConnectionState.connected,
    batteryPercent: 68,
  );

  static const unpairedDevice = RingDevice(
    id: 'ring-unpaired',
    displayName: '云遥戒指',
    connectionState: DeviceConnectionState.unpaired,
    batteryPercent: 0,
  );

  static const pairedSnapshot = DeviceDaySnapshot(
    device: pairedDevice,
    headline: '昨夜睡眠良好 · 静息心率稳定',
    sleep: NightSleepSummary(
      duration: Duration(hours: 7, minutes: 42),
      qualityLabel: '良好',
      insight: '深睡偏充足，醒来精神更稳',
      score: 82,
    ),
    heartRate: HeartRateReading(
      bpm: 58,
      kindLabel: '静息心率',
      baselineHint: '接近你的近期基线',
    ),
  );

  static const unpairedSnapshot = DeviceDaySnapshot(
    device: unpairedDevice,
    headline: '配对戒指后，同步睡眠与心率',
  );

  static const recommendations = <DeviceContentAction>[
    DeviceContentAction(
      title: '思绪停机',
      subtitle: '睡眠 · 快速入睡',
      kind: DeviceContentActionKind.sleep,
    ),
    DeviceContentAction(
      title: '安抚焦虑',
      subtitle: '冥想 · 情绪急救',
      kind: DeviceContentActionKind.meditation,
    ),
    DeviceContentAction(
      title: '清晨温柔苏醒',
      subtitle: '冥想 · 日间活力',
      kind: DeviceContentActionKind.meditation,
    ),
  ];
}
