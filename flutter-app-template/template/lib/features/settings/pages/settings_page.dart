import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/ops/diagnostics_access.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final access = Get.find<DiagnosticsAccess>();

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.settingsTitle),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.only(bottom: tokens.spaceLg),
        children: [
          const AppSectionHeader('Ops demos'),
          Obx(
            () => FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.settingsLogEvent),
                  onPress: () async {
                    await controller.logDemoEvent();
                    if (!context.mounted) return;
                    AppToast.success(context, 'Event logged');
                  },
                ),
                FTile(
                  title: Text(l10n.settingsFeatureFlag),
                  subtitle: Text('${controller.demoFlag.value}'),
                  suffix: const Icon(FLucideIcons.refreshCw),
                  onPress: controller.refreshFlag,
                ),
                if (controller.canTriggerTestCrash)
                  FTile(
                    title: Text(l10n.settingsTestCrash),
                    onPress: () async {
                      final ok = await AppDialog.showConfirm(
                        context,
                        title: 'Trigger test crash?',
                        message: 'Records a non-fatal error (dev only).',
                        confirmLabel: 'Crash',
                        destructive: true,
                      );
                      if (ok != true) return;
                      await controller.triggerTestCrash();
                      if (!context.mounted) return;
                      AppToast.info(context, 'Test error recorded');
                    },
                  ),
                FTile(
                  title: Text(l10n.settingsHeartbeat),
                  onPress: () async {
                    await AppLoadingOverlay.during(
                      context,
                      controller.sendHeartbeat,
                      message: 'Sending…',
                    );
                    if (!context.mounted) return;
                    AppToast.success(context, 'Heartbeat sent');
                  },
                ),
                if (access.canShowSettingsEntry)
                  FTile(
                    title: const Text('Diagnostics'),
                    subtitle: Text(access.isDev ? 'dev' : 'flag enabled'),
                    onPress: () => Get.toNamed(
                      AppRoutes.diagnostics,
                      parameters: {'source': 'settings'},
                    ),
                  ),
              ],
            ),
          ),
          Obx(() {
            final event = controller.lastEvent.value;
            if (event == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Text('${l10n.settingsLastEvent}: $event'),
            );
          }),
        ],
      ),
    );
  }
}
