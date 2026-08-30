import 'package:get/get.dart';

import '../../core/assets/healing_assets.dart';
import '../../core/haptics/healing_haptics.dart';
import '../../core/audio/app_audio_coordinator.dart';
import '../../core/lifecycle/app_lifecycle_audio.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../sleep_session/sleep_session_controller.dart';

class RootShellController extends GetxController {
  final activeTab = HealingRootTab.home.obs;
  final tabSlideForward = true.obs;

  AppLifecycleAudio? _lifecycleAudio;

  @override
  void onInit() {
    super.onInit();
    _lifecycleAudio = AppLifecycleAudio(Get.find<AppAudioCoordinator>());
    _lifecycleAudio!.attach();
    _restoreActiveSleepSession();
  }

  @override
  void onClose() {
    _lifecycleAudio?.detach();
    super.onClose();
  }

  Future<void> requestTab(HealingRootTab tab) async {
    if (tab == activeTab.value) return;

    final previousIndex = HealingRootTab.ordered.indexOf(activeTab.value);
    final nextIndex = HealingRootTab.ordered.indexOf(tab);
    tabSlideForward.value = nextIndex > previousIndex;

    HealingHaptics.selection();
    activeTab.value = tab;
  }

  Future<void> _restoreActiveSleepSession() async {
    final repo = Get.find<SleepRepository>();
    final active = await repo.activeSession();
    if (active == null) return;

    if (!Get.isRegistered<SleepSessionController>()) {
      Get.put(
        SleepSessionController(sleepRepository: repo),
        permanent: true,
      );
    }
    await Get.find<SleepSessionController>().restoreActive();
  }
}
