import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../domain/services/sound_audio_player.dart';
import '../../root_shell/root_shell_controller.dart';
import 'home_greeting_copy.dart';
import 'home_scene_catalog.dart';

class HomeSceneController extends GetxController {
  HomeSceneController(this._audioPlayer);

  final SoundAudioPlayer _audioPlayer;

  final pageController = PageController();
  final currentIndex = 0.obs;
  final soundEnabled = false.obs;
  final copyOpacity = 0.0.obs;
  final indicatorsHidden = false.obs;
  final greetingTitle = ''.obs;
  final greetingHint = ''.obs;

  Timer? _copyTimer;
  Timer? _indicatorHideTimer;
  Worker? _tabWorker;

  static const _copyDelay = Duration(seconds: 1);
  static const _copyVisibleDuration = Duration(seconds: 3);
  static const _indicatorIdleBeforeHide = Duration(seconds: 4);

  HomeScene get currentScene => HomeSceneCatalog.scenes[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _refreshGreeting();
    _restartCopyAnimation();
    _scheduleIndicatorHide();
    _tabWorker = ever(
      Get.find<RootShellController>().activeTab,
      (HealingRootTab tab) {
        if (tab == HealingRootTab.home) {
          _refreshGreeting();
          _showIndicators();
          _scheduleIndicatorHide();
        } else {
          unawaited(_mute());
        }
      },
    );
    ever(soundEnabled, (_) => _refreshGreetingHint());
  }

  @override
  void onClose() {
    _copyTimer?.cancel();
    _indicatorHideTimer?.cancel();
    _tabWorker?.dispose();
    unawaited(_audioPlayer.stop());
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _showIndicators();
    _scheduleIndicatorHide();
    _restartCopyAnimation();
    if (soundEnabled.value) {
      unawaited(_playCurrent());
    }
  }

  Future<void> onSceneTap() async {
    _showIndicators();
    _scheduleIndicatorHide();
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

  Future<void> goToScene(String sceneId, {bool autoplay = false}) async {
    final index = HomeSceneCatalog.scenes.indexWhere((s) => s.id == sceneId);
    if (index < 0) return;

    if (pageController.hasClients) {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      currentIndex.value = index;
      onPageChanged(index);
    }

    if (autoplay) {
      soundEnabled.value = true;
      await _playCurrent();
    }
  }

  void _refreshGreeting() {
    final now = DateTime.now();
    greetingTitle.value = HomeGreetingCopy.title(now);
    _refreshGreetingHint(now: now);
  }

  void _refreshGreetingHint({DateTime? now}) {
    final time = now ?? DateTime.now();
    greetingHint.value = soundEnabled.value
        ? HomeGreetingCopy.soundOnHint(time)
        : HomeGreetingCopy.soundOffHint(time);
  }

  void _showIndicators() {
    indicatorsHidden.value = false;
  }

  void _scheduleIndicatorHide() {
    _indicatorHideTimer?.cancel();
    _indicatorHideTimer = Timer(_indicatorIdleBeforeHide, () {
      indicatorsHidden.value = true;
    });
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

  void _restartCopyAnimation() {
    _copyTimer?.cancel();
    copyOpacity.value = 0.0;

    _copyTimer = Timer(_copyDelay, () {
      copyOpacity.value = 1.0;
      _copyTimer = Timer(_copyVisibleDuration, () {
        copyOpacity.value = 0.0;
      });
    });
  }
}
