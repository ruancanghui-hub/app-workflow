import '../domain/models/sound_asset.dart';
import '../domain/models/sound_playback_source.dart';

const _amazonJungle =
    'assets/sounds/freesound_community-amazon-jungle-day-crickets-birds-and-frogs-from-boat-on-river-great-spread2-some-occasional-boat-rocking-52759.mp3';
const _zablocieForest =
    'assets/sounds/freesound_community-zablocie-forest-birds-nature-reserve-19018.mp3';
const _birdsWind =
    'assets/sounds/freesound_community-birds-singing-in-and-leaves-rustling-with-the-wind-14557.mp3';

/// 首发静态声景目录（≥6，免费 ≥3），对齐 MVP 5.1。
const kLaunchSoundCatalog = <SoundAsset>[
  SoundAsset(
    id: 'valley_rain',
    title: '山谷雨声',
    subtitle: '专注 · 自然录音',
    tags: ['自然', '雨林', '虫鸣'],
    isFree: true,
    durationMinutes: 45,
    isFeatured: true,
    playback: SoundPlaybackSource.bundled(_amazonJungle),
  ),
  SoundAsset(
    id: 'pine_forest',
    title: '松林夜风',
    subtitle: '放松 · 林间鸟鸣',
    tags: ['自然', '森林'],
    isFree: true,
    durationMinutes: 60,
    playback: SoundPlaybackSource.bundled(_zablocieForest),
  ),
  SoundAsset(
    id: 'ocean_waves',
    title: '溪涧林声',
    subtitle: '入睡 · 流水',
    tags: ['自然', '溪流'],
    isFree: true,
    durationMinutes: 90,
    playback: const SoundPlaybackSource.remote('shuiliu.mp3'),
  ),
  SoundAsset(
    id: 'white_noise',
    title: '白噪声时刻',
    subtitle: '屏蔽 · 风声鸟鸣',
    tags: ['白噪', '自然'],
    isFree: false,
    durationMinutes: 30,
    isFeatured: true,
    playback: SoundPlaybackSource.bundled(_birdsWind),
  ),
  SoundAsset(
    id: 'fireplace',
    title: '壁炉轻响',
    subtitle: '温暖 · 网站音频',
    tags: ['室内'],
    isFree: false,
    durationMinutes: 45,
    playback: SoundPlaybackSource.remote('fireplace.mp3'),
  ),
  SoundAsset(
    id: 'city_night',
    title: '城市夜雨',
    subtitle: '陪伴 · 网站音频',
    tags: ['雨声', '城市'],
    isFree: false,
    durationMinutes: 50,
    playback: SoundPlaybackSource.remote('city_night.mp3'),
  ),
];
