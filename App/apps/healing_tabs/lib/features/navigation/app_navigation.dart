import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../sleep_session/sleep_session_controller.dart';

void openPlayer(String soundId) {
  Get.toNamed('${AppRoutes.player}/$soundId');
}

void openBreath() => Get.toNamed(AppRoutes.breath);

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
