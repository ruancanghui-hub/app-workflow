import '../../../data/sound_catalog_data.dart';
import '../../../domain/models/sleep_content.dart';
import '../../../domain/models/sound_asset.dart';
import '../../tabs/home/home_scene_catalog.dart';

/// 提审用诚实目录：仅展示有真实可播素材、标题与音频一致的自然声景。
abstract final class SleepContentCatalog {
  static final featured = <SleepFeaturedItem>[
    for (var i = 0; i < 4 && i < HomeSceneCatalog.scenes.length; i++)
      SleepFeaturedItem(
        title: HomeSceneCatalog.scenes[i].title,
        subtitle: '自然白噪音 · ${HomeSceneCatalog.scenes[i].copy}',
        soundId: HomeSceneCatalog.scenes[i].id,
        coverImageAsset: HomeSceneCatalog.scenes[i].backgroundAsset,
      ),
  ];

  static final categories = _buildCategories();

  static List<SleepContentCategory> _buildCategories() {
    final scenes = HomeSceneCatalog.scenes;
    final sleepSounds = kLaunchSoundCatalog
        .where((s) => s.isFree && s.tags.contains('睡眠'))
        .toList();

    return [
      SleepContentCategory(
        id: 'white_noise',
        title: '自然白噪音',
        hint: '包内场景录音，所见即所听',
        items: [
          for (var i = 0; i < scenes.length; i++)
            SleepContentItem(
              title: scenes[i].title,
              subtitle: scenes[i].copy,
              kind: SleepContentKind.whiteNoise,
              soundId: scenes[i].id,
              practiceMinutes: 60,
              coverImageAsset: scenes[i].backgroundAsset,
            ),
        ],
      ),
      _moodistCategory(
        id: 'sleep_rain',
        title: '雨声入眠',
        hint: '细雨、暴雨与窗前雨滴',
        groupTag: '雨声',
        sounds: sleepSounds,
      ),
      _moodistCategory(
        id: 'sleep_nature',
        title: '自然夜声',
        hint: '海浪、溪流与林间风声',
        groupTag: '自然声景',
        sounds: sleepSounds,
      ),
      _moodistCategory(
        id: 'sleep_noise',
        title: '白噪助眠',
        hint: '稳定背景声，减少环境干扰',
        groupTag: '白噪音',
        sounds: sleepSounds,
      ),
      _moodistCategory(
        id: 'sleep_animals',
        title: '夜间动物',
        hint: '虫鸣、猫呼噜与深海鲸歌',
        groupTag: '自然动物',
        sounds: sleepSounds,
      ),
      _moodistCategory(
        id: 'sleep_indoor',
        title: '室内陪伴',
        hint: '风扇、时钟与轻柔家居声',
        groupTag: '日常器物',
        sounds: sleepSounds,
      ),
    ];
  }

  static SleepContentCategory _moodistCategory({
    required String id,
    required String title,
    required String hint,
    required String groupTag,
    required List<SoundAsset> sounds,
  }) {
    final categorySounds = sounds.where(
      (sound) => sound.tags.contains(groupTag),
    );
    return SleepContentCategory(
      id: id,
      title: title,
      hint: hint,
      items: [
        for (final sound in categorySounds)
          SleepContentItem(
            title: sound.title,
            subtitle: sound.subtitle,
            kind: SleepContentKind.pureMusic,
            soundId: sound.id,
            practiceMinutes: sound.durationMinutes,
            coverImageAsset: 'assets/images/sound/cover_art/${sound.id}.png',
          ),
      ],
    );
  }
}
