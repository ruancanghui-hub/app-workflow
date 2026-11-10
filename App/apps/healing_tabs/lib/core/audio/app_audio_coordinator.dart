import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/health/playback_window_recorder.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/services/sound_audio_player.dart';
import '../../features/tabs/home/home_scene_controller.dart';
import 'healing_audio_handler.dart';

enum AppAudioOwner { none, homeScene, player }

/// 全局唯一音频会话：应用内持续播放，仅在新音频明确开播时替换。
class AppAudioCoordinator extends GetxService {
  AppAudioCoordinator(this._player) {
    _playingSub = _player.playingStream.listen(_onEnginePlaying);
  }

  final SoundAudioPlayer _player;
  StreamSubscription<bool>? _playingSub;

  final activeOwner = AppAudioOwner.none.obs;
  final activeContentId = RxnString();
  final isPlaying = false.obs;
  final nowPlayingTitle = RxnString();
  final nowPlayingSubtitle = RxnString();
  final nowPlayingCover = RxnString();

  /// Engine position for lock-screen / notification progress.
  Stream<Duration> get positionStream => _player.positionStream;

  Future<Duration> get position => _player.position;

  Duration? get duration => _player.duration;

  /// `sleep` / `meditation` 等；仅冥想落播放时间窗。
  String? _playerScenario;
  var _playerWindowActive = false;

  bool get hasPlayerSession =>
      activeOwner.value == AppAudioOwner.player &&
      (activeContentId.value?.isNotEmpty ?? false);

  bool get _shouldRecordMeditationWindow => _playerScenario == 'meditation';

  void _onEnginePlaying(bool playing) {
    if (activeOwner.value == AppAudioOwner.none) {
      if (isPlaying.value) isPlaying.value = false;
      return;
    }
    if (isPlaying.value != playing) {
      isPlaying.value = playing;
      _syncHomeSoundEnabled();
    }
    // 不在此联动心率：playingStream 与 stop()/play() 时序交错时，
    // 晚到的 false 会把刚 acquire 的监测关掉。
  }

  Future<void> playHomeScene(String sceneId, String assetPath) async {
    await _syncPlayerHeartRate(playing: false);
    _playerScenario = null;
    await _player.stop();
    await _player.prepareAsset(assetPath);
    await _player.play();
    activeOwner.value = AppAudioOwner.homeScene;
    activeContentId.value = sceneId;
    isPlaying.value = true;
    _clearNowPlayingMeta();
    _syncHomeSoundEnabled();
  }

  Future<void> playSoundAsset(
    String soundId,
    SoundAsset asset, {
    String? title,
    String? subtitle,
    String? coverImageAsset,
    String scenario = 'sleep',
  }) async {
    _playerScenario = scenario;
    // 先挂会话再动引擎，避免 stop/play 的 playing 回调打乱心率占用。
    activeOwner.value = AppAudioOwner.player;
    activeContentId.value = soundId;
    nowPlayingTitle.value = title ?? asset.title;
    nowPlayingSubtitle.value = subtitle ?? asset.subtitle;
    nowPlayingCover.value = coverImageAsset;
    if (Get.isRegistered<HealingAudioHandler>()) {
      await Get.find<HealingAudioHandler>().ensureNotificationPermission();
    }
    await _player.stop();
    await _player.prepare(asset);
    await _syncPlayerHeartRate(playing: true);
    await _player.play();
    isPlaying.value = true;
    _syncHomeSoundEnabled();
  }

  /// 从暂停恢复，不重新 prepare（避免重头播放）。
  Future<void> resume() async {
    if (activeOwner.value == AppAudioOwner.none) return;
    isPlaying.value = true;
    await _player.play();
    _syncHomeSoundEnabled();
    if (activeOwner.value == AppAudioOwner.player) {
      await _syncPlayerHeartRate(playing: true);
    }
  }

  Future<void> pause() async {
    isPlaying.value = false;
    await _player.pause();
    _syncHomeSoundEnabled();
    if (activeOwner.value == AppAudioOwner.player) {
      await _syncPlayerHeartRate(playing: false);
    }
  }

  Future<void> togglePlayerPlayPause() async {
    if (!hasPlayerSession) return;
    if (isPlaying.value) {
      await pause();
    } else {
      await resume();
    }
  }

  /// 停止播放器会话并清除迷你条元数据。
  Future<void> stopPlayer() async {
    if (activeOwner.value != AppAudioOwner.player) return;
    await _syncPlayerHeartRate(playing: false);
    await _player.stop();
    activeOwner.value = AppAudioOwner.none;
    activeContentId.value = null;
    isPlaying.value = false;
    _playerScenario = null;
    _clearNowPlayingMeta();
    _syncHomeSoundEnabled();
  }

  Future<void> releaseOwner(AppAudioOwner owner) async {
    if (activeOwner.value != owner) return;
    if (owner == AppAudioOwner.player) {
      await _syncPlayerHeartRate(playing: false);
      _playerScenario = null;
    }
    await _player.pause();
    activeOwner.value = AppAudioOwner.none;
    activeContentId.value = null;
    isPlaying.value = false;
    if (owner == AppAudioOwner.player) {
      _clearNowPlayingMeta();
    }
    _syncHomeSoundEnabled();
  }

  bool isHomeScenePlaying(String sceneId) =>
      activeOwner.value == AppAudioOwner.homeScene &&
      activeContentId.value == sceneId &&
      isPlaying.value;

  bool isPlayerSoundPlaying(String soundId) =>
      activeOwner.value == AppAudioOwner.player &&
      activeContentId.value == soundId &&
      isPlaying.value;

  bool isPlayerSoundSession(String soundId) =>
      activeOwner.value == AppAudioOwner.player &&
      activeContentId.value == soundId;

  Future<void> _syncPlayerHeartRate({required bool playing}) async {
    if (!_shouldRecordMeditationWindow) {
      if (_playerWindowActive) {
        _playerWindowActive = false;
        if (Get.isRegistered<PlaybackWindowRecorder>()) {
          await Get.find<PlaybackWindowRecorder>().end();
        }
      }
      return;
    }
    final recorder = Get.isRegistered<PlaybackWindowRecorder>()
        ? Get.find<PlaybackWindowRecorder>()
        : null;
    if (recorder == null) return;
    if (playing) {
      if (_playerWindowActive) return;
      _playerWindowActive = true;
      await recorder.begin(
        contentId: activeContentId.value ?? 'unknown',
        title: nowPlayingTitle.value ?? '冥想',
      );
      debugPrint('[PlaybackWindow] started meditation');
    } else if (_playerWindowActive) {
      _playerWindowActive = false;
      await recorder.end();
      debugPrint('[PlaybackWindow] ended meditation');
    }
  }

  void _clearNowPlayingMeta() {
    nowPlayingTitle.value = null;
    nowPlayingSubtitle.value = null;
    nowPlayingCover.value = null;
  }

  void _syncHomeSoundEnabled() {
    if (!Get.isRegistered<HomeSceneController>()) return;
    final home = Get.find<HomeSceneController>();
    home.soundEnabled.value =
        activeOwner.value == AppAudioOwner.homeScene && isPlaying.value;
  }

  @override
  void onClose() {
    unawaited(_syncPlayerHeartRate(playing: false));
    unawaited(_playingSub?.cancel() ?? Future<void>.value());
    _playingSub = null;
    super.onClose();
  }
}
