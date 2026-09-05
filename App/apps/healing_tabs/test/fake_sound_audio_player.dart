import 'dart:async';

import 'package:healing_tabs/domain/models/sound_asset.dart';
import 'package:healing_tabs/domain/services/sound_audio_player.dart';

class FakeSoundAudioPlayer implements SoundAudioPlayer {
  final _positionController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();

  SoundAsset? lastPrepared;
  bool isPlaying = false;
  Duration _position = Duration.zero;
  Duration? trackDuration = const Duration(minutes: 3);

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Future<Duration> get position async => _position;

  @override
  Duration? get duration => trackDuration;

  @override
  Future<void> prepare(SoundAsset asset) async {
    lastPrepared = asset;
    _position = Duration.zero;
    _positionController.add(_position);
  }

  @override
  Future<void> prepareAsset(String assetPath) async {
    lastPrepared = null;
    _position = Duration.zero;
    _positionController.add(_position);
  }

  @override
  Future<void> play() async {
    isPlaying = true;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    isPlaying = false;
    _playingController.add(false);
  }

  @override
  Future<void> stop() async {
    isPlaying = false;
    _position = Duration.zero;
    _positionController.add(_position);
    _playingController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    final max = trackDuration ?? const Duration(hours: 1);
    var next = position;
    if (next.isNegative) next = Duration.zero;
    if (next > max) next = max;
    _position = next;
    _positionController.add(_position);
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _playingController.close();
  }

  void disposeForTest() {
    _positionController.close();
    _playingController.close();
  }
}
