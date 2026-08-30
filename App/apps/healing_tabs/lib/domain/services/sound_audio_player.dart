import '../models/sound_asset.dart';

abstract class SoundAudioPlayer {
  Stream<Duration> get positionStream;

  Future<void> prepare(SoundAsset asset);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}
