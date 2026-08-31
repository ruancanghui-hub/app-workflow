import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/assets/healing_assets.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../root_shell/root_shell_controller.dart';
import '../tabs/home/home_scene_controller.dart';
import '../sleep_session/sleep_session_controller.dart';

void openPlayer(String soundId, {String scenario = 'sleep'}) {
  Get.toNamed('${AppRoutes.player}/$soundId?scenario=$scenario');
}

/// 从声景库跳转到首页指定场景；[autoplay] 为 true 时同时开启环境声。
Future<void> openHomeScene(String sceneId, {bool autoplay = false}) async {
  await Get.find<RootShellController>().requestTab(HealingRootTab.home);
  await Get.find<HomeSceneController>().goToScene(sceneId, autoplay: autoplay);
}

void openBreath() => Get.toNamed(AppRoutes.breath);

void openSleepPicker() => Get.toNamed(AppRoutes.sleepPicker);

void openMeditationPractice(int minutes) =>
    Get.toNamed(AppRoutes.meditationPractice, arguments: minutes);

void openSleepReport(SleepSession session) {
  Get.toNamed(AppRoutes.sleepReport, arguments: session);
}

Future<void> openSleepSession({String? soundId}) async {
  if (!Get.isRegistered<SleepSessionController>()) {
    Get.put(
      SleepSessionController(sleepRepository: Get.find<SleepRepository>()),
      permanent: true,
    );
  }
  await Get.find<SleepSessionController>().start(soundId: soundId);
  await Get.toNamed(AppRoutes.sleepSession);
}
