import '../../../data/sound_catalog_data.dart';
import '../../../domain/models/meditation_content.dart';
import '../../../domain/models/sound_asset.dart';
import '../../tabs/home/home_scene_catalog.dart';

/// 提审用诚实目录：仅展示有真实可播素材、标题与音频一致的自然声景。
abstract final class MeditationContentCatalog {
  static final featured = <MeditationFeaturedItem>[
    for (var i = 0; i < 4 && i < HomeSceneCatalog.scenes.length; i++)
      MeditationFeaturedItem(
        title: HomeSceneCatalog.scenes[i].title,
        subtitle: '专注 · 自然声景',
        soundId: HomeSceneCatalog.scenes[i].id,
        coverImageAsset: HomeSceneCatalog.scenes[i].backgroundAsset,
      ),
  ];

  static final categories = _buildCategories();

  static List<MeditationContentCategory> _buildCategories() {
    final scenes = HomeSceneCatalog.scenes;
    final meditationSounds = kLaunchSoundCatalog
        .where((s) => s.isFree && s.tags.contains('冥想'))
        .toList();

    return [
      MeditationContentCategory(
        id: 'daytime_energy',
        title: '日间声景',
        hint: '包内场景录音，所见即所听',
        items: [
          for (var i = 0; i < scenes.length; i++)
            MeditationContentItem(
              title: scenes[i].title,
              subtitle: scenes[i].copy,
              kind: MeditationContentKind.daytimeEnergy,
              soundId: scenes[i].id,
              practiceMinutes: 30,
              coverImageAsset: scenes[i].backgroundAsset,
            ),
        ],
      ),
      _moodistCategory(
        id: 'meditation_binaural',
        title: '脑波练习',
        hint: '阿尔法、西塔等专注节律',
        groupTag: '脑波节律',
        sounds: meditationSounds,
      ),
      _moodistCategory(
        id: 'meditation_places',
        title: '沉浸场所',
        hint: '图书馆、咖啡馆与静谧空间',
        groupTag: '场所氛围',
        sounds: meditationSounds,
      ),
      _moodistCategory(
        id: 'meditation_transport',
        title: '旅途漫游',
        hint: '列车、帆船与远行环境',
        groupTag: '旅途环境',
        sounds: meditationSounds,
      ),
      _moodistCategory(
        id: 'meditation_urban',
        title: '城市专注',
        hint: '城市脉动与背景人声',
        groupTag: '城市环境',
        sounds: meditationSounds,
      ),
      _moodistCategory(
        id: 'meditation_animals',
        title: '自然观察',
        hint: '鸟鸣、牧野与林间生灵',
        groupTag: '自然动物',
        sounds: meditationSounds,
      ),
      _moodistCategory(
        id: 'meditation_everyday',
        title: '日常专注',
        hint: '纸张、键盘与生活细响',
        groupTag: '日常器物',
        sounds: meditationSounds,
      ),
    ];
  }

  static MeditationContentCategory _moodistCategory({
    required String id,
    required String title,
    required String hint,
    required String groupTag,
    required List<SoundAsset> sounds,
  }) {
    final categorySounds = sounds.where(
      (sound) => sound.tags.contains(groupTag),
    );
    return MeditationContentCategory(
      id: id,
      title: title,
      hint: hint,
      items: [
        for (final sound in categorySounds)
          MeditationContentItem(
            title: sound.title,
            subtitle: sound.subtitle,
            kind: MeditationContentKind.quickRelief,
            soundId: sound.id,
            practiceMinutes: sound.durationMinutes,
            coverImageAsset: 'assets/images/sound/cover_art/${sound.id}.png',
          ),
      ],
    );
  }
}
