import 'package:app_template/core/env/app_environment.dart';
import 'package:app_template/core/identity/app_instance_identity.dart';
import 'package:app_template/core/ops/analytics.dart';
import 'package:app_template/core/ops/app_events.dart';
import 'package:app_template/core/ops/crash_reporter.dart';
import 'package:app_template/core/ops/remote_config.dart';
import 'package:app_template/core/ops_console/ops_console_reporter.dart';
import 'package:app_template/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAnalytics analytics;
  late AppEvents appEvents;
  late FakeRemoteConfig remoteConfig;
  late FakeCrashReporter crashReporter;
  late FakeOpsConsoleReporter ops;
  late SettingsController controller;

  setUp(() {
    analytics = FakeAnalytics();
    appEvents = AppEvents(analytics);
    remoteConfig = FakeRemoteConfig({'demo_flag': true});
    crashReporter = FakeCrashReporter();
    ops = FakeOpsConsoleReporter(
      const AppInstanceIdentity(appId: 'a', displayName: 'n'),
    );
    controller = SettingsController(
      appEvents: appEvents,
      remoteConfig: remoteConfig,
      crashReporter: crashReporter,
      environment: FakeAppEnvironment(BuildVariant.dev),
      opsConsoleReporter: ops,
    )..onInit();
  });

  test('logDemoEvent records analytics', () async {
    await controller.logDemoEvent();
    expect(analytics.events.single.name, 'settings_demo_tap');
  });

  test('demo flag readable', () {
    expect(controller.demoFlag.value, isTrue);
  });

  test('test crash only in dev', () async {
    await controller.triggerTestCrash();
    expect(crashReporter.reports, hasLength(1));

    final prod = SettingsController(
      appEvents: appEvents,
      remoteConfig: remoteConfig,
      crashReporter: crashReporter,
      environment: FakeAppEnvironment(BuildVariant.prod),
      opsConsoleReporter: ops,
    );
    await prod.triggerTestCrash();
    expect(crashReporter.reports, hasLength(1));
  });

  test('heartbeat', () async {
    await controller.sendHeartbeat();
    expect(ops.heartbeats, hasLength(1));
  });
}
