import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../domain/services/sound_audio_player.dart';
import '../../root_shell/root_shell_controller.dart';
import 'home_scene_catalog.dart';

class HomeSceneController extends GetxController {
  HomeSceneController(this._audioPlayer);

  final SoundAudioPlayer _audioPlayer;

  final pageController = PageController();
  final currentIndex = 0.obs;
  final soundEnabled = false.obs;
  final visibleChars = 0.obs;

  Timer? _typeTimer;
  Worker? _tabWorker;

  HomeScene get currentScene => HomeSceneCatalog.scenes[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _restartTypewriter();
    _tabWorker = ever(
      Get.find<RootShellController>().activeTab,
      (HealingRootTab tab) {
        if (tab != HealingRootTab.home) {
          unawaited(_mute());
        }
      },
    );
  }

  @override
  void onClose() {
    _typeTimer?.cancel();
    _tabWorker?.dispose();
    unawaited(_audioPlayer.stop());
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _restartTypewriter();
    if (soundEnabled.value) {
      unawaited(_playCurrent());
    }
  }

  Future<void> onSceneTap() async {
    if (soundEnabled.value) {
      await _mute();
    } else {
      soundEnabled.value = true;
      await _playCurrent();
    }
  }

  Future<void> toggleSound() async {
    if (soundEnabled.value) {
      await _mute();
    } else {
      soundEnabled.value = true;
      await _playCurrent();
    }
  }

  Future<void> _mute() async {
    soundEnabled.value = false;
    await _audioPlayer.pause();
  }

  Future<void> _playCurrent() async {
    try {
      await _audioPlayer.stop();
      final scene = currentScene;
      await _audioPlayer.prepareAsset(scene.soundAsset);
      await _audioPlayer.play();
    } catch (_) {
      soundEnabled.value = false;
    }
  }

  void _restartTypewriter() {
    _typeTimer?.cancel();
    visibleChars.value = 0;
    final text = currentScene.copy;
    if (text.isEmpty) return;

    _typeTimer = Timer.periodic(const Duration(milliseconds: 85), (timer) {
      if (visibleChars.value >= text.length) {
        timer.cancel();
        return;
      }
      visibleChars.value++;
    });
  }
}
