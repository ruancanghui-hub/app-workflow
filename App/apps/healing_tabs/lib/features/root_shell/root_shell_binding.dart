import 'dart:io';

import 'package:get/get.dart';

import '../../core/audio/app_audio_coordinator.dart';
import '../../core/audio/healing_audio_handler.dart';
import '../../core/http/http_client.dart';
import '../../core/storage/key_value_store.dart';
import '../../data/device_repository_impl.dart';
import '../../data/health/apple_health_repository.dart';
import '../../data/health/playback_window_recorder.dart';
import '../../data/health/unsupported_health_repository.dart';
import '../../data/heart_rate_repository_impl.dart';
import '../../data/identity_repository_impl.dart';
import '../../data/just_audio_player_service.dart';
import '../../data/remote_sound_api.dart';
import '../../data/sleep_repository_impl.dart'; // SettingsRepositoryImpl
import '../../data/sound_repository_impl.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/health_data_repository.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../../domain/repositories/identity_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/sound_repository.dart';
import '../../domain/services/sound_audio_player.dart';
import '../device/rest_data_controller.dart';
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
    if (!Get.isRegistered<HealthDataRepository>()) {
      final HealthDataRepository health = Platform.isIOS
          ? AppleHealthRepository(store)
          : UnsupportedHealthRepository();
      Get.put<HealthDataRepository>(health, permanent: true);
    }
    if (!Get.isRegistered<HeartRateRepository>()) {
      Get.put<HeartRateRepository>(
        HeartRateRepositoryImpl(
          store: store,
          health: Get.find<HealthDataRepository>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<PlaybackWindowRecorder>()) {
      Get.put(
        PlaybackWindowRecorder(
          heartRateRepository: Get.find<HeartRateRepository>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DeviceRepository>()) {
      Get.put<DeviceRepository>(DeviceRepositoryImpl(store), permanent: true);
    }
    if (!Get.isRegistered<RestDataController>()) {
      Get.put(
        RestDataController(
          deviceRepository: Get.find<DeviceRepository>(),
          health: Get.find<HealthDataRepository>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SettingsRepository>()) {
      Get.put<SettingsRepository>(SettingsRepositoryImpl(store), permanent: true);
    }
    if (!Get.isRegistered<IdentityRepository>()) {
      Get.put<IdentityRepository>(
        IdentityRepositoryImpl(store),
        permanent: true,
      );
      Get.find<IdentityRepository>().ensureLocalAccount();
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
    if (Get.isRegistered<HealingAudioHandler>()) {
      Get.find<HealingAudioHandler>().attach(Get.find<AppAudioCoordinator>());
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
