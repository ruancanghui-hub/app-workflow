import 'health_vitals.dart';

export 'health_vitals.dart';

/// 休息 Tab 推荐内容入口。
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

/// 兼容旧调用：把 [NightSleepData] 展成摘要卡可用字段。
extension NightSleepDataView on NightSleepData {
  String get displayInsight => insight ?? '来自 Apple 健康';
}
