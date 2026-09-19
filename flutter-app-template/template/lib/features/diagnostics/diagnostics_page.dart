import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/identity/app_instance_identity.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/firebase_bootstrap.dart';
import '../../core/ops/jank_monitor.dart';
import '../../core/ops/remote_config.dart';
import '../../core/ops_console/ops_console_reporter.dart';
import '../../core/ui/ui.dart';

class DiagnosticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DiagnosticsController(
        environment: Get.find<AppEnvironment>(),
        identity: Get.find<AppInstanceIdentity>(),
        remoteConfig: Get.find<RemoteConfig>(),
        jankMonitor: Get.find<JankMonitor>(),
        opsConsoleReporter: Get.find<OpsConsoleReporter>(),
        firebaseBootstrap: Get.find<FirebaseBootstrap>(),
        appEvents: Get.find<AppEvents>(),
      ),
    );
  }
}

class DiagnosticsController extends GetxController {
  DiagnosticsController({
    required this.environment,
    required this.identity,
    required this.remoteConfig,
    required this.jankMonitor,
    required this.opsConsoleReporter,
    required this.firebaseBootstrap,
    required this.appEvents,
  });

  final AppEnvironment environment;
  final AppInstanceIdentity identity;
  final RemoteConfig remoteConfig;
  final JankMonitor jankMonitor;
  final OpsConsoleReporter opsConsoleReporter;
  final FirebaseBootstrap firebaseBootstrap;
  final AppEvents appEvents;

  final lastHeartbeatOk = RxnBool();
  final firebaseReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseReady.value = firebaseBootstrap.initialized;
    appEvents.diagnosticsOpen(source: Get.parameters['source'] ?? 'unknown');
  }

  Future<void> pingHeartbeat() async {
    await opsConsoleReporter.heartbeat();
    lastHeartbeatOk.value = true;
  }

  String buildSummary() {
    final buf = StringBuffer()
      ..writeln('variant=${environment.variant.name}')
      ..writeln('appId=${identity.appId}')
      ..writeln('displayName=${identity.displayName}')
      ..writeln('firebaseReady=${firebaseReady.value}')
      ..writeln('demo_flag=${remoteConfig.getBool('demo_flag')}')
      ..writeln(
        'jank_monitor_enabled=${remoteConfig.isFeatureEnabled('jank_monitor_enabled', defaultValue: true)}',
      )
      ..writeln(
        'diagnostics_entry_enabled=${remoteConfig.isFeatureEnabled('diagnostics_entry_enabled')}',
      )
      ..writeln('recentJankCount=${jankMonitor.recentJankCount}')
      ..writeln('lastHeartbeatOk=${lastHeartbeatOk.value}');
    return buf.toString();
  }

  Future<void> copySummary() async {
    await Clipboard.setData(ClipboardData(text: buildSummary()));
  }
}

class DiagnosticsPage extends GetView<DiagnosticsController> {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Diagnostics'),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: ListView(
        children: [
          const AppSectionHeader('Identity'),
          FTileGroup(
            children: [
              FTile(
                title: const Text('Build variant'),
                details: Text(controller.environment.variant.name),
              ),
              FTile(
                title: const Text('App ID'),
                details: Text(controller.identity.appId),
              ),
              FTile(
                title: const Text('Display name'),
                details: Text(controller.identity.displayName),
              ),
            ],
          ),
          const AppSectionHeader('Ops'),
          Obx(
            () => FTileGroup(
              children: [
                FTile(
                  title: const Text('Firebase ready'),
                  details: Text('${controller.firebaseReady.value}'),
                ),
                FTile(
                  title: const Text('demo_flag'),
                  details: Text('${controller.remoteConfig.getBool('demo_flag')}'),
                ),
                FTile(
                  title: const Text('jank_monitor_enabled'),
                  details: Text(
                    '${controller.remoteConfig.isFeatureEnabled('jank_monitor_enabled', defaultValue: true)}',
                  ),
                ),
                FTile(
                  title: const Text('diagnostics_entry_enabled'),
                  details: Text(
                    '${controller.remoteConfig.isFeatureEnabled('diagnostics_entry_enabled')}',
                  ),
                ),
                FTile(
                  title: const Text('Recent jank count'),
                  details: Text('${controller.jankMonitor.recentJankCount}'),
                ),
                FTile(
                  title: const Text('Last heartbeat'),
                  details: Text('${controller.lastHeartbeatOk.value ?? '-'}'),
                  onPress: controller.pingHeartbeat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              onPress: controller.copySummary,
              child: const Text('Copy diagnostics summary'),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Template diagnostics — not a public settings surface.',
              style: theme.typography.body.xs
                  .copyWith(color: theme.colors.mutedForeground),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
