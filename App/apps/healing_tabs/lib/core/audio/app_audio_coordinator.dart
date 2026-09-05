import 'package:get/get.dart';

import '../../domain/models/sound_asset.dart';
import '../../domain/services/sound_audio_player.dart';
import '../../features/tabs/home/home_scene_controller.dart';

enum AppAudioOwner { none, homeScene, player }

/// 全局唯一音频会话：应用内持续播放，仅在新音频明确开播时替换。
class AppAudioCoordinator extends GetxService {
  AppAudioCoordinator(this._player);

  final SoundAudioPlayer _player;

  final activeOwner = AppAudioOwner.none.obs;
  final activeContentId = RxnString();
  final isPlaying = false.obs;
  final nowPlayingTitle = RxnString();
  final nowPlayingSubtitle = RxnString();
  final nowPlayingCover = RxnString();

  bool get hasPlayerSession =>
      activeOwner.value == AppAudioOwner.player &&
      (activeContentId.value?.isNotEmpty ?? false);

  Future<void> playHomeScene(String sceneId, String assetPath) async {
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
  }) async {
    await _player.stop();
    await _player.prepare(asset);
    await _player.play();
    activeOwner.value = AppAudioOwner.player;
    activeContentId.value = soundId;
    isPlaying.value = true;
    nowPlayingTitle.value = title ?? asset.title;
    nowPlayingSubtitle.value = subtitle ?? asset.subtitle;
    nowPlayingCover.value = coverImageAsset;
    _syncHomeSoundEnabled();
  }

  /// 从暂停恢复，不重新 prepare（避免重头播放）。
  Future<void> resume() async {
    if (activeOwner.value == AppAudioOwner.none) return;
    await _player.play();
    isPlaying.value = true;
    _syncHomeSoundEnabled();
  }

  Future<void> pause() async {
    await _player.pause();
    isPlaying.value = false;
    _syncHomeSoundEnabled();
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
    await _player.stop();
    activeOwner.value = AppAudioOwner.none;
    activeContentId.value = null;
    isPlaying.value = false;
    _clearNowPlayingMeta();
    _syncHomeSoundEnabled();
  }

  Future<void> releaseOwner(AppAudioOwner owner) async {
    if (activeOwner.value != owner) return;
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
}
