import '../../../domain/models/device_content.dart';

/// 戒指 Tab 未配对占位与推荐文案；已配对体征由 BLE 同步填充。
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
      insight: '昨夜监测已同步（演示模板，配对后显示真实摘要）',
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
      title: '悠静晨林',
      subtitle: '自然白噪音 · 助眠',
      kind: DeviceContentActionKind.sleep,
    ),
    DeviceContentAction(
      title: '森林溪流',
      subtitle: '自然声景 · 专注',
      kind: DeviceContentActionKind.meditation,
    ),
    DeviceContentAction(
      title: '山谷雨声',
      subtitle: '自然录音 · 放松',
      kind: DeviceContentActionKind.sleep,
    ),
  ];
}
