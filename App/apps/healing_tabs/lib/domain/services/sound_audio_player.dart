import '../models/sound_asset.dart';

abstract class SoundAudioPlayer {
  Stream<Duration> get positionStream;

  Future<void> prepare(SoundAsset asset);

  /// 直接加载 pubspec 中声明的包内音频路径（如 `assets/sounds/foo.mp3`）。
  Future<void> prepareAsset(String assetPath);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}
