import '../../../domain/models/local_account.dart';

/// 「我的」页摘要；仅使用真实可推导字段，不写死演示历史。
abstract final class MeContentCatalog {
  static MeUsageSummary usageSummary({
    required LocalAccount account,
    required int favoriteCount,
    String? lastSleepLabel,
  }) {
    final days = DateTime.now().difference(account.createdAt).inDays + 1;
    return MeUsageSummary(
      streakDays: days.clamp(1, 9999),
      favoriteCount: favoriteCount,
      lastActivityLabel: lastSleepLabel ?? '暂无睡眠记录',
    );
  }
}
