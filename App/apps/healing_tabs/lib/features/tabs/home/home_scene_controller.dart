import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/audio/app_audio_coordinator.dart';
import '../../root_shell/root_shell_controller.dart';
import 'home_greeting_copy.dart';
import 'home_scene_catalog.dart';

class HomeSceneController extends GetxController {
  HomeSceneController(this._audio);

  final AppAudioCoordinator _audio;

  final pageController = PageController();
  final currentIndex = 0.obs;
  final soundEnabled = false.obs;
  final copyBlockOpacity = 0.0.obs;
  final titleOpacity = 0.0.obs;
  final typedCopy = ''.obs;
  final indicatorsHidden = false.obs;
  final greetingTitle = ''.obs;
  final greetingHint = ''.obs;

  Timer? _copyTimer;
  Timer? _typeTimer;
  Timer? _indicatorHideTimer;
  Worker? _tabWorker;

  static const _copyDelay = Duration(milliseconds: 800);
  static const _titleHold = Duration(milliseconds: 420);
  static const _typeStep = Duration(milliseconds: 68);
  static const _holdBeforeFade = Duration(milliseconds: 1600);
  static const _indicatorIdleBeforeHide = Duration(seconds: 4);

  HomeScene get currentScene => HomeSceneCatalog.scenes[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _refreshGreeting();
    _syncSoundEnabledFromCoordinator();
    _restartCopyAnimation();
    _scheduleIndicatorHide();
    _tabWorker = ever(
      Get.find<RootShellController>().activeTab,
      (HealingRootTab tab) {
        if (tab == HealingRootTab.home) {
          _refreshGreeting();
          _syncSoundEnabledFromCoordinator();
          _showIndicators();
          _scheduleIndicatorHide();
        }
      },
    );
    ever(soundEnabled, (_) => _refreshGreetingHint());
  }

  @override
  void onClose() {
    _copyTimer?.cancel();
    _typeTimer?.cancel();
    _indicatorHideTimer?.cancel();
    _tabWorker?.dispose();
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

  void _syncSoundEnabledFromCoordinator() {
    final scene = currentScene;
    soundEnabled.value = _audio.isHomeScenePlaying(scene.id);
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
    await _audio.releaseOwner(AppAudioOwner.homeScene);
  }

  Future<void> _playCurrent() async {
    try {
      final scene = currentScene;
      await _audio.playHomeScene(scene.id, scene.soundAsset);
      soundEnabled.value = true;
    } catch (_) {
      soundEnabled.value = false;
    }
  }

  void _restartCopyAnimation() {
    _copyTimer?.cancel();
    _typeTimer?.cancel();
    copyBlockOpacity.value = 0.0;
    titleOpacity.value = 0.0;
    typedCopy.value = '';

    _copyTimer = Timer(_copyDelay, () {
      copyBlockOpacity.value = 1.0;
      titleOpacity.value = 1.0;
      _copyTimer = Timer(_titleHold, _typeNextChar);
    });
  }

  void _typeNextChar() {
    final full = currentScene.copy;
    final nextLen = typedCopy.value.length + 1;
    if (nextLen > full.characters.length) {
      _copyTimer = Timer(_holdBeforeFade, () {
        copyBlockOpacity.value = 0.0;
        titleOpacity.value = 0.0;
      });
      return;
    }
    typedCopy.value = full.characters.take(nextLen).toString();
    _typeTimer = Timer(_typeStep, _typeNextChar);
  }
}
