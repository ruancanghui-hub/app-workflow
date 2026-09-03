/// 本机云遥账号（由设备身份驱动，无感登录）。
class LocalAccount {
  const LocalAccount({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.avatarAsset,
  });

  /// 稳定本机身份 ID（首次安装生成并持久化）。
  final String id;

  final String displayName;
  final DateTime createdAt;
  final String? avatarAsset;

  LocalAccount copyWith({
    String? displayName,
    String? avatarAsset,
  }) =>
      LocalAccount(
        id: id,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt,
        avatarAsset: avatarAsset ?? this.avatarAsset,
      );
}

class MeUsageSummary {
  const MeUsageSummary({
    required this.streakDays,
    required this.favoriteCount,
    required this.lastActivityLabel,
  });

  final int streakDays;
  final int favoriteCount;
  final String lastActivityLabel;
}

class MePlayHistoryItem {
  const MePlayHistoryItem({
    required this.title,
    required this.subtitle,
    required this.playedAtLabel,
  });

  final String title;
  final String subtitle;
  final String playedAtLabel;
}
