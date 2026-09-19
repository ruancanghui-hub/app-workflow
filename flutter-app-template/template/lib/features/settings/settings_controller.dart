import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/crash_reporter.dart';
import '../../core/ops/remote_config.dart';
import '../../core/ops_console/ops_console_reporter.dart';

class SettingsController extends GetxController {
  SettingsController({
    required this.appEvents,
    required this.remoteConfig,
    required this.crashReporter,
    required this.environment,
    required this.opsConsoleReporter,
  });

  final AppEvents appEvents;
  final RemoteConfig remoteConfig;
  final CrashReporter crashReporter;
  final AppEnvironment environment;
  final OpsConsoleReporter opsConsoleReporter;

  final lastEvent = RxnString();
  final demoFlag = false.obs;
  final lastHeartbeatOk = false.obs;

  bool get canTriggerTestCrash => environment.isDev;

  @override
  void onInit() {
    super.onInit();
    demoFlag.value = remoteConfig.isFeatureEnabled('demo_flag');
  }

  Future<void> logDemoEvent() async {
    await appEvents.settingsDemoTap();
    lastEvent.value = 'settings_demo_tap';
  }

  Future<void> refreshFlag() async {
    await remoteConfig.fetchAndActivate();
    demoFlag.value = remoteConfig.isFeatureEnabled('demo_flag');
  }

  Future<void> triggerTestCrash() async {
    if (!canTriggerTestCrash) return;
    final error = StateError('dev-only test exception');
    await crashReporter.recordError(error, StackTrace.current, fatal: false);
  }

  Future<void> sendHeartbeat() async {
    await opsConsoleReporter.heartbeat();
    lastHeartbeatOk.value = true;
  }
}
