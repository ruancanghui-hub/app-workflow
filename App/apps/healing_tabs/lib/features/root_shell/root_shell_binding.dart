import 'package:get/get.dart';

import '../../core/audio/app_audio_coordinator.dart';
import '../../core/http/http_client.dart';
import '../../core/storage/key_value_store.dart';
import '../../data/just_audio_player_service.dart';
import '../../data/remote_sound_api.dart';
import '../../data/sleep_repository_impl.dart';
import '../../data/sound_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/sound_repository.dart';
import '../../domain/services/sound_audio_player.dart';
import '../sound_catalog/sound_catalog_controller.dart';
import '../tabs/home/home_scene_controller.dart';
import 'root_shell_controller.dart';

class RootShellBinding extends Bindings {
  @override
  void dependencies() {
    final store = Get.find<KeyValueStore>();
    if (!Get.isRegistered<SoundRepository>()) {
      final http = Get.find<HttpClient>();
      Get.put<SoundRepository>(
        SoundRepositoryImpl(store, RemoteSoundApi(http)),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SleepRepository>()) {
      Get.put<SleepRepository>(SleepRepositoryImpl(store), permanent: true);
    }
    if (!Get.isRegistered<SettingsRepository>()) {
      Get.put<SettingsRepository>(SettingsRepositoryImpl(store), permanent: true);
    }
    if (!Get.isRegistered<SoundAudioPlayer>()) {
      Get.put<SoundAudioPlayer>(JustAudioPlayerService(), permanent: true);
    }
    if (!Get.isRegistered<AppAudioCoordinator>()) {
      Get.put<AppAudioCoordinator>(
        AppAudioCoordinator(Get.find<SoundAudioPlayer>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SoundCatalogController>()) {
      Get.lazyPut(
        () => SoundCatalogController(Get.find<SoundRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HomeSceneController>()) {
      Get.lazyPut(
        () => HomeSceneController(Get.find<AppAudioCoordinator>()),
        fenix: true,
      );
    }
    Get.lazyPut(RootShellController.new);
  }
}
