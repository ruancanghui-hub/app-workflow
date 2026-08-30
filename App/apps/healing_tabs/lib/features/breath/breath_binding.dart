import 'package:get/get.dart';

import 'breath_controller.dart';

class BreathBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(BreathController.new);
  }
}
