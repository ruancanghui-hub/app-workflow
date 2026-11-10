import '../../../domain/models/device_content.dart';

/// 休息 Tab 空态与推荐文案；已连接体征由 Apple 健康填充。
abstract final class DeviceContentCatalog {
  static const disconnectedSnapshot = RestDaySnapshot(
    authState: HealthAuthState.disconnected,
    headline: '连接 Apple 健康，查看本地休息摘要',
  );

  static const connectedNoDataSnapshot = RestDaySnapshot(
    authState: HealthAuthState.connectedNoData,
    headline: '已连接 Apple 健康，暂无休息数据',
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
