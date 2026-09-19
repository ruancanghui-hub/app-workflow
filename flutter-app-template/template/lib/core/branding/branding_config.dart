/// Branding values from dart-define (seeded by instance.config.yaml apply).
///
/// **Quick replace checklist** for the 启动品牌页:
/// - [logoAsset] / `assets/branding/logo.png` — brand mark
/// - [slogan] — short line under the app name
/// - [copyright] — footer line
/// - [splashMinMs] — minimum cold-start display duration
/// - [onboardingVersion] — bump to re-show 引导页 after a major update
class BrandingConfig {
  const BrandingConfig({
    required this.slogan,
    required this.splashMinMs,
    required this.logoAsset,
    required this.copyright,
    required this.onboardingVersion,
  });

  factory BrandingConfig.fromEnvironment() => const BrandingConfig(
        slogan: String.fromEnvironment(
          'APP_SLOGAN',
          defaultValue: 'Ship faster with a solid foundation.',
        ),
        splashMinMs: int.fromEnvironment('APP_SPLASH_MIN_MS', defaultValue: 800),
        logoAsset: String.fromEnvironment(
          'APP_LOGO_ASSET',
          defaultValue: 'assets/branding/logo.png',
        ),
        copyright: String.fromEnvironment(
          'APP_COPYRIGHT',
          defaultValue: '© 2026 Your Company',
        ),
        onboardingVersion: String.fromEnvironment(
          'APP_ONBOARDING_VERSION',
          defaultValue: '1',
        ),
      );

  final String slogan;
  final int splashMinMs;
  final String logoAsset;
  final String copyright;
  final String onboardingVersion;
}
