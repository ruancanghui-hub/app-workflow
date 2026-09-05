/// 睡眠日：以中午 12:00 为切点的统计窗口。
abstract final class SleepDay {
  /// 给定时刻所属睡眠日的起点（当日或前一日 12:00）。
  static DateTime startOf(DateTime instant) {
    final local = instant.toLocal();
    final noon = DateTime(local.year, local.month, local.day, 12);
    if (local.isBefore(noon)) {
      return noon.subtract(const Duration(days: 1));
    }
    return noon;
  }

  static String idOf(DateTime instant) {
    final s = startOf(instant);
    return '${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}';
  }

  /// 从 [anchor] 往回共 [count] 个睡眠日起点（含当日），时间正序。
  static List<DateTime> recentStarts(DateTime anchor, {int count = 7}) {
    final today = startOf(anchor);
    return List.generate(
      count,
      (i) => today.subtract(Duration(days: count - 1 - i)),
    );
  }
}
