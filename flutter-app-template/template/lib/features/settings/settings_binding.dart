import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/crash_reporter.dart';
import '../../core/ops/remote_config.dart';
import '../../core/ops_console/ops_console_reporter.dart';
import 'settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SettingsController(
        appEvents: Get.find<AppEvents>(),
        remoteConfig: Get.find<RemoteConfig>(),
        crashReporter: Get.find<CrashReporter>(),
        environment: Get.find<AppEnvironment>(),
        opsConsoleReporter: Get.find<OpsConsoleReporter>(),
      ),
    );
  }
}
