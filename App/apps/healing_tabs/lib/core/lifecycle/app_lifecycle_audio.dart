import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../audio/app_audio_coordinator.dart';
import '../../features/player/player_controller.dart';

/// 切后台时暂停播放；回前台由用户手动继续。
class AppLifecycleAudio extends WidgetsBindingObserver {
  AppLifecycleAudio(this._audio);

  final AppAudioCoordinator _audio;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_audio.isPlaying.value) return;

      unawaited(_audio.pause());

      if (Get.isRegistered<PlayerController>()) {
        final controller = Get.find<PlayerController>();
        if (controller.status.value == PlayerStatus.playing) {
          controller.pauseForInterruption();
        }
      }
    }
  }
}
