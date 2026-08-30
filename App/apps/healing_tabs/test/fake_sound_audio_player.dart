import 'dart:async';

import 'package:healing_tabs/domain/models/sound_asset.dart';
import 'package:healing_tabs/domain/services/sound_audio_player.dart';

class FakeSoundAudioPlayer implements SoundAudioPlayer {
  final _positionController = StreamController<Duration>.broadcast();

  SoundAsset? lastPrepared;
  bool isPlaying = false;
  Duration position = Duration.zero;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Future<void> prepare(SoundAsset asset) async {
    lastPrepared = asset;
    position = Duration.zero;
    _positionController.add(position);
  }

  @override
  Future<void> prepareAsset(String assetPath) async {
    lastPrepared = null;
    position = Duration.zero;
    _positionController.add(position);
  }

  @override
  Future<void> play() async {
    isPlaying = true;
  }

  @override
  Future<void> pause() async {
    isPlaying = false;
  }

  @override
  Future<void> stop() async {
    isPlaying = false;
    position = Duration.zero;
    _positionController.add(position);
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
  }

  void disposeForTest() {
    _positionController.close();
  }
}
