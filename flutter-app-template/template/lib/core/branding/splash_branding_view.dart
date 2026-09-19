import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/identity/app_instance_identity.dart';
import '../../core/ui/ui.dart';
import 'branding_config.dart';

/// Shared 启动品牌页 layout (logo, name, slogan, optional loader, copyright).
///
/// Used by [SplashPage] and Catalog splash preview so instances replace one place.
class SplashBrandingView extends StatelessWidget {
  const SplashBrandingView({
    required this.branding,
    required this.initializingLabel,
    this.showLoading = false,
    this.displayName,
    super.key,
  });

  final BrandingConfig branding;
  final String initializingLabel;
  final bool showLoading;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final identity = Get.isRegistered<AppInstanceIdentity>()
        ? Get.find<AppInstanceIdentity>()
        : const AppInstanceIdentity(
            appId: 'app_template_local',
            displayName: 'App Template',
          );
    final name = displayName ?? identity.displayName;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                branding.logoAsset,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  FLucideIcons.box,
                  size: 72,
                  color: theme.colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: theme.typography.display.xl
                  .copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              branding.slogan,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (showLoading) ...[
              const FCircularProgress.loader(),
              const SizedBox(height: 12),
              Text(
                initializingLabel,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              branding.copyright,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
