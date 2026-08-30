import 'package:get/get.dart';

import '../../domain/repositories/sleep_repository.dart';
import 'sleep_session_controller.dart';

class SleepSessionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SleepSessionController>()) {
      Get.put(
        SleepSessionController(sleepRepository: Get.find<SleepRepository>()),
        permanent: true,
      );
    }
    Get.find<SleepSessionController>().restoreActive();
  }
}
