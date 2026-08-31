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

  Future<void> playHomeScene(String sceneId, String assetPath) async {
    await _player.stop();
    await _player.prepareAsset(assetPath);
    await _player.play();
    activeOwner.value = AppAudioOwner.homeScene;
    activeContentId.value = sceneId;
    isPlaying.value = true;
    _syncHomeSoundEnabled();
  }

  Future<void> playSoundAsset(String soundId, SoundAsset asset) async {
    await _player.stop();
    await _player.prepare(asset);
    await _player.play();
    activeOwner.value = AppAudioOwner.player;
    activeContentId.value = soundId;
    isPlaying.value = true;
    _syncHomeSoundEnabled();
  }

  Future<void> pause() async {
    await _player.pause();
    isPlaying.value = false;
  }

  Future<void> releaseOwner(AppAudioOwner owner) async {
    if (activeOwner.value != owner) return;
    await _player.pause();
    activeOwner.value = AppAudioOwner.none;
    activeContentId.value = null;
    isPlaying.value = false;
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

  void _syncHomeSoundEnabled() {
    if (!Get.isRegistered<HomeSceneController>()) return;
    final home = Get.find<HomeSceneController>();
    home.soundEnabled.value =
        activeOwner.value == AppAudioOwner.homeScene && isPlaying.value;
  }
}
