import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../l10n/app_localizations.dart';
import '../home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = FTheme.of(context);

    return FScaffold(
      header: FHeader(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!controller.titleTapDetector.registerTap()) return;
            Get.toNamed(
              AppRoutes.diagnostics,
              parameters: {'source': 'secret_tap'},
            );
          },
          child: Text(l10n.homeTitle),
        ),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.settings),
            onPress: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeHello,
              style: theme.typography.display.xl
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: tokens.spaceMd),
            AppAppear(
              child: FCard(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionHeader('Build', padding: EdgeInsets.zero),
                      const SizedBox(height: 8),
                      Text(l10n.homeVariant(controller.variantLabel)),
                      const SizedBox(height: 12),
                      Text(
                        l10n.homeDiagnosticsHint,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        onPress: () => Get.toNamed(AppRoutes.catalog),
                        child: Text(l10n.homeOpenCatalog),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        variant: AppButtonVariant.secondary,
                        onPress: () => Get.toNamed(AppRoutes.settings),
                        child: Text(l10n.homeOpenSettings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
