/// 首页沉浸式场景：背景图 [home_bg] + 包内音频 [assets/sounds]。
library;

import '../../../domain/models/sound_asset.dart';
import '../../../domain/models/sound_playback_source.dart';

class HomeScene {
  const HomeScene({
    required this.id,
    required this.title,
    required this.copy,
    required this.backgroundAsset,
    required this.soundAsset,
  });

  final String id;
  final String title;
  final String copy;
  final String backgroundAsset;
  final String soundAsset;
}

abstract final class HomeSceneCatalog {
  static const scenes = <HomeScene>[
    HomeScene(
      id: 'morning_forest',
      title: '悠静晨林',
      copy: '晨光穿过叶隙，鸟鸣唤醒沉睡的山谷。',
      backgroundAsset: 'assets/images/home/home_bg/悠静晨林.png',
      soundAsset: 'assets/sounds/悠静晨林.mp3',
    ),
    HomeScene(
      id: 'quiet_mountain_path',
      title: '宁静山路',
      copy: '石阶蜿蜒入林深处，脚步渐轻，心事渐远。',
      backgroundAsset: 'assets/images/home/home_bg/宁静山路.PNG',
      soundAsset: 'assets/sounds/宁静山路.wav',
    ),
    HomeScene(
      id: 'forest_stream',
      title: '森林溪流',
      copy: '溪水潺潺穿行林间，带走白日的倦意。',
      backgroundAsset: 'assets/images/home/home_bg/森林溪流.PNG',
      soundAsset: 'assets/sounds/森林溪流.mp3',
    ),
    HomeScene(
      id: 'mountain_cloud_sea',
      title: '山间云海',
      copy: '云海翻涌于足下，天地间只余呼吸与静默。',
      backgroundAsset: 'assets/images/home/home_bg/山间云海.PNG',
      soundAsset: 'assets/sounds/山间云海.wav',
    ),
    HomeScene(
      id: 'cherry_valley',
      title: '樱花山谷',
      copy: '落樱如雪，拂过面颊的是春天的温柔。',
      backgroundAsset: 'assets/images/home/home_bg/樱花山谷.PNG',
      soundAsset: 'assets/sounds/樱花山谷.mp3',
    ),
    HomeScene(
      id: 'lakeside_moon',
      title: '湖畔月夜',
      copy: '湖光映月，夜深时与繁星私语。',
      backgroundAsset: 'assets/images/home/home_bg/湖畔月夜.PNG',
      soundAsset: 'assets/sounds/湖畔月夜.wav',
    ),
    HomeScene(
      id: 'sunset_beach',
      title: '海边落日沙滩',
      copy: '浪声轻拍沙滩，落日把天空染成橘粉。',
      backgroundAsset: 'assets/images/home/home_bg/海边落日沙滩.PNG',
      soundAsset: 'assets/sounds/海边落日沙滩.mp3',
    ),
    HomeScene(
      id: 'snow_mountain',
      title: '雪山静谧',
      copy: '雪山不语，却在无声中抚平一切波澜。',
      backgroundAsset: 'assets/images/home/home_bg/雪山静谧.PNG',
      soundAsset: 'assets/sounds/雪山静谧.wav',
    ),
  ];

  /// 声景库展示与收藏用的 [SoundAsset] 视图（与首页场景一一对应）。
  static List<SoundAsset> get soundAssets => scenes
      .map(
        (scene) => SoundAsset(
          id: scene.id,
          title: scene.title,
          subtitle: scene.copy,
          tags: const ['场景', '包内'],
          isFree: true,
          durationMinutes: 60,
          isFeatured: scene.id == scenes.first.id,
          playback: SoundPlaybackSource.bundled(scene.soundAsset),
        ),
      )
      .toList(growable: false);

  static final Set<String> sceneIds = {for (final s in scenes) s.id};
}
