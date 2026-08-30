import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/assets/healing_assets.dart';
import '../../core/haptics/healing_haptics.dart';
import '../../core/lifecycle/app_lifecycle_audio.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/services/sound_audio_player.dart';
import '../sleep_session/sleep_session_controller.dart';

class RootShellController extends GetxController {
  final activeTab = HealingRootTab.home.obs;

  AppLifecycleAudio? _lifecycleAudio;

  @override
  void onInit() {
    super.onInit();
    _lifecycleAudio = AppLifecycleAudio(Get.find<SoundAudioPlayer>());
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

    final active = await Get.find<SleepRepository>().activeSession();
    if (active != null) {
      final proceed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF1A2028),
          title: const Text('睡眠会话进行中', style: TextStyle(color: Colors.white)),
          content: const Text(
            '切换页签不会结束本次睡眠记录，计时仍会继续。',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('留下'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('继续切换'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

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
