import '../models/sound_asset.dart';

abstract class SoundAudioPlayer {
  Stream<Duration> get positionStream;

  Future<Duration> get position;

  /// 当前素材时长；未知时为 null。
  Duration? get duration;

  Future<void> prepare(SoundAsset asset);

  /// 直接加载 pubspec 中声明的包内音频路径（如 `assets/sounds/foo.mp3`）。
  Future<void> prepareAsset(String assetPath);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seek(Duration position);

  Future<void> dispose();
}
