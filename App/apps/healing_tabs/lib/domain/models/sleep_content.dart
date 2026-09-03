/// 睡眠 Tab 内容分类与单集条目（领域模型，不含 UI/路由实现）。
enum SleepContentKind {
  quickFallAsleep,
  nightReentry,
  insomniaAnxiety,
  sleepStory,
  whiteNoise,
  pureMusic,
  yogaNidra,
  powerNap,
}

class SleepFeaturedItem {
  const SleepFeaturedItem({
    required this.title,
    required this.subtitle,
    required this.soundId,
    required this.coverImageAsset,
  });

  final String title;
  final String subtitle;
  final String soundId;
  final String coverImageAsset;
}

class SleepContentItem {
  const SleepContentItem({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.coverImageAsset,
    this.soundId,
    this.practiceMinutes = 10,
  });

  final String title;
  final String subtitle;
  final SleepContentKind kind;
  final String coverImageAsset;
  final String? soundId;
  final int practiceMinutes;
}

class SleepContentCategory {
  const SleepContentCategory({
    required this.id,
    required this.title,
    required this.items,
    this.hint,
  });

  final String id;
  final String title;
  final String? hint;
  final List<SleepContentItem> items;
}
