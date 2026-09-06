import '../../../data/sound_catalog_data.dart';
import '../../../domain/models/sleep_content.dart';
import '../../tabs/home/home_scene_catalog.dart';
import 'sleep_cover_art.dart';

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
    final launchFree = kLaunchSoundCatalog.where((s) => s.isFree).toList();

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
      SleepContentCategory(
        id: 'pure_music',
        title: '助眠声景',
        hint: '首发自然录音',
        items: [
          for (var i = 0; i < launchFree.length; i++)
            SleepContentItem(
              title: launchFree[i].title,
              subtitle: launchFree[i].subtitle,
              kind: SleepContentKind.pureMusic,
              soundId: launchFree[i].id,
              practiceMinutes: launchFree[i].durationMinutes,
              coverImageAsset: SleepCoverArt.at(i),
            ),
        ],
      ),
    ];
  }
}
