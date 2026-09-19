import 'package:get/get.dart';

import '../../core/branding/splash_page.dart';
import '../../core/ui/ui.dart';
import '../../features/catalog/catalog_binding.dart';
import '../../features/catalog/catalog_page.dart';
import '../../features/catalog/catalog_refresh_page.dart';
import '../../features/catalog/catalog_splash_preview_page.dart';
import '../../features/catalog/catalog_transition_page.dart';
import '../../features/diagnostics/diagnostics_page.dart';
import '../../features/feedback/feedback_page.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/onboarding/onboarding_binding.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/settings/settings_binding.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashPage.new,
    ),
    SharedAxisGetPage(
      name: AppRoutes.home,
      page: HomePage.new,
      binding: HomeBinding(),
      axis: SharedAxisTransitionType.scaled,
    ),
    FadeThroughGetPage(
      name: AppRoutes.settings,
      page: SettingsPage.new,
      binding: SettingsBinding(),
    ),
    FadeScaleGetPage(
      name: AppRoutes.diagnostics,
      page: DiagnosticsPage.new,
      binding: DiagnosticsBinding(),
    ),
    FadeThroughGetPage(
      name: AppRoutes.onboarding,
      page: OnboardingPage.new,
      binding: OnboardingBinding(),
    ),
    FadeThroughGetPage(
      name: AppRoutes.feedback,
      page: FeedbackPage.new,
      binding: FeedbackBinding(),
    ),
    FadeThroughGetPage(
      name: AppRoutes.catalog,
      page: CatalogPage.new,
      binding: CatalogBinding(),
    ),
    SharedAxisGetPage(
      name: AppRoutes.catalogSharedAxis,
      page: () => const CatalogTransitionPage(title: 'Shared axis'),
      axis: SharedAxisTransitionType.horizontal,
    ),
    FadeThroughGetPage(
      name: AppRoutes.catalogFadeThrough,
      page: () => const CatalogTransitionPage(title: 'Fade through'),
    ),
    FadeScaleGetPage(
      name: AppRoutes.catalogFadeScale,
      page: () => const CatalogTransitionPage(title: 'Fade scale'),
    ),
    SharedAxisGetPage(
      name: AppRoutes.catalogRefresh,
      page: CatalogRefreshPage.new,
      binding: CatalogBinding(),
    ),
    FadeThroughGetPage(
      name: AppRoutes.catalogSplashPreview,
      page: CatalogSplashPreviewPage.new,
    ),
    FadeThroughGetPage(
      name: AppRoutes.catalogOnboarding,
      page: OnboardingPage.new,
      binding: OnboardingBinding(preview: true),
    ),
  ];
}
