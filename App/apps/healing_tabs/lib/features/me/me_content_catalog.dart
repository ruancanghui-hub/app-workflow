import '../../../domain/models/local_account.dart';

/// 「我的」页演示用摘要与历史（收藏数由仓库实时取）。
abstract final class MeContentCatalog {
  static MeUsageSummary usageSummary({required int favoriteCount}) {
    return MeUsageSummary(
      streakDays: 3,
      favoriteCount: favoriteCount,
      lastActivityLabel: '昨夜睡眠 7小时42分',
    );
  }

  static const history = <MePlayHistoryItem>[
    MePlayHistoryItem(
      title: '思绪停机',
      subtitle: '睡眠 · 快速入睡',
      playedAtLabel: '昨天晚上',
    ),
    MePlayHistoryItem(
      title: '安抚焦虑',
      subtitle: '冥想 · 情绪急救',
      playedAtLabel: '昨天中午',
    ),
    MePlayHistoryItem(
      title: '清晨温柔苏醒',
      subtitle: '冥想 · 日间活力',
      playedAtLabel: '今天早上',
    ),
  ];
}
