import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeController(environment: Get.find<AppEnvironment>()),
    );
  }
}
