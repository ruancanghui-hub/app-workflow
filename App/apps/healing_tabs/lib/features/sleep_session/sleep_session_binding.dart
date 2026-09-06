import 'dart:async';

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
    final controller = Get.find<SleepSessionController>();
    // 刚从「开始睡眠」写入的内存会话不要被异步 restore 冲掉。
    if (controller.session.value == null) {
      unawaited(controller.restoreActive());
    }
  }
}
