import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../domain/services/sound_audio_player.dart';
import '../../features/player/player_controller.dart';

/// 切后台时暂停播放；回前台若仍在播放器页，由用户手动继续。
class AppLifecycleAudio extends WidgetsBindingObserver {
  AppLifecycleAudio(this._audioPlayer);

  final SoundAudioPlayer _audioPlayer;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (Get.isRegistered<PlayerController>()) {
        final controller = Get.find<PlayerController>();
        if (controller.status.value == PlayerStatus.playing) {
          controller.pauseForInterruption();
        }
      } else {
        _audioPlayer.pause();
      }
    }
  }
}
