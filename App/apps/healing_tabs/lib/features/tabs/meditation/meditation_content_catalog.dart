import '../../../data/sound_catalog_data.dart';
import '../../../domain/models/meditation_content.dart';
import '../../tabs/home/home_scene_catalog.dart';
import 'meditation_cover_art.dart';

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
    final launchFree = kLaunchSoundCatalog.where((s) => s.isFree).toList();

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
      MeditationContentCategory(
        id: 'quick_relief',
        title: '专注白噪',
        hint: '首发自然录音',
        items: [
          for (var i = 0; i < launchFree.length; i++)
            MeditationContentItem(
              title: launchFree[i].title,
              subtitle: launchFree[i].subtitle,
              kind: MeditationContentKind.quickRelief,
              soundId: launchFree[i].id,
              practiceMinutes: launchFree[i].durationMinutes,
              coverImageAsset: MeditationCoverArt.at(i),
            ),
        ],
      ),
    ];
  }
}
