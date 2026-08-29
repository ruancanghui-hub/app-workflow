import 'package:get/get.dart';

import 'root_shell_controller.dart';

class RootShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(RootShellController.new);
  }
}
