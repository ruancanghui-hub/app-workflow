/// 冥想 Tab 内容分类与单集条目（领域模型，不含 UI/路由实现）。
enum MeditationContentKind {
  quickRelief,
  emotionFirstAid,
  selfGrowth,
  workplace,
  studyFocus,
  daytimeEnergy,
  socialRepair,
  multiDaySeries,
}

class MeditationFeaturedItem {
  const MeditationFeaturedItem({
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

class MeditationContentItem {
  const MeditationContentItem({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.coverImageAsset,
    this.soundId,
    this.practiceMinutes = 10,
  });

  final String title;
  final String subtitle;
  final MeditationContentKind kind;
  final String coverImageAsset;
  final String? soundId;
  final int practiceMinutes;
}

class MeditationContentCategory {
  const MeditationContentCategory({
    required this.id,
    required this.title,
    required this.items,
    this.hint,
  });

  final String id;
  final String title;
  final String? hint;
  final List<MeditationContentItem> items;
}
