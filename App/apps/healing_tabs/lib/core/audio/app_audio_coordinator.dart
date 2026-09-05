import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/ble/playback_heart_rate_sampler.dart';
import '../../data/ble/yc_ble_ring_service.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/services/sound_audio_player.dart';
import '../../features/tabs/home/home_scene_controller.dart';

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

  /// `sleep` / `meditation` 等；用于判断是否联动戒指心率。
  String? _playerScenario;
  var _playerHrAcquired = false;

  bool get hasPlayerSession =>
      activeOwner.value == AppAudioOwner.player &&
      (activeContentId.value?.isNotEmpty ?? false);

  bool get _shouldMonitorHrOnPlayer =>
      _playerScenario == 'sleep' || _playerScenario == 'meditation';

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
    if (!Get.isRegistered<YcBleRingService>()) {
      debugPrint('[HR] skip: YcBleRingService not registered');
      return;
    }
    final ble = Get.find<YcBleRingService>();
    final sampler = Get.isRegistered<PlaybackHeartRateSampler>()
        ? Get.find<PlaybackHeartRateSampler>()
        : null;
    if (playing && _shouldMonitorHrOnPlayer) {
      if (_playerHrAcquired) {
        debugPrint('[HR] already acquired, skip');
        return;
      }
      final ok = await ble.acquirePlaybackHeartRate(RingHrMonitorOwner.player);
      if (!ok) {
        debugPrint(
          '[HR] acquire failed scenario=$_playerScenario '
          'connected=${ble.isConnected.value}',
        );
        return;
      }
      _playerHrAcquired = true;
      await sampler?.begin(
        owner: 'player',
        kind: _playerScenario ?? 'sleep',
        contentId: activeContentId.value,
        title: nowPlayingTitle.value,
      );
      debugPrint('[HR] monitoring started scenario=$_playerScenario');
    } else if (_playerHrAcquired) {
      await sampler?.end(owner: 'player');
      await ble.releasePlaybackHeartRate(RingHrMonitorOwner.player);
      _playerHrAcquired = false;
      debugPrint('[HR] monitoring stopped');
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
