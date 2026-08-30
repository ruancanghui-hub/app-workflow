import 'package:get/get.dart';

import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/sound_repository.dart';
import '../../domain/services/sound_audio_player.dart';
import 'player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayerController>(
      () => PlayerController(
        soundRepository: Get.find<SoundRepository>(),
        sleepRepository: Get.find<SleepRepository>(),
        audioPlayer: Get.find<SoundAudioPlayer>(),
      ),
    );
  }
}
