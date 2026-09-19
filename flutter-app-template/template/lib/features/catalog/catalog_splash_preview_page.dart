import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/branding/branding_config.dart';
import '../../core/branding/splash_branding_view.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';

/// Catalog-only preview of the 启动品牌页 layout (no cold-start navigation).
class CatalogSplashPreviewPage extends StatelessWidget {
  const CatalogSplashPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branding = BrandingConfig.fromEnvironment();

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.catalogPreviewSplash),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: SplashBrandingView(
        branding: branding,
        initializingLabel: l10n.splashInitializing,
        showLoading: true,
      ),
    );
  }
}
