import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/branding/onboarding_gate.dart';
import '../../core/ops/analytics.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/firebase_analytics_adapter.dart';
import '../../core/ops/jank_monitor.dart';
import '../../core/ops/store_review_launcher.dart';
import '../../core/ops/umeng_analytics_adapter.dart';
import '../../core/ops/umeng_bootstrap.dart';
import '../../core/storage/key_value_store.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';

class CatalogController extends GetxController {
  CatalogController({
    required this.appEvents,
    required this.analytics,
    required this.jankMonitor,
    required this.store,
  });

  final AppEvents appEvents;
  final Analytics analytics;
  final JankMonitor jankMonitor;
  final KeyValueStore store;

  final buttonLoading = false.obs;
  final lastEventLabel = RxnString();
  final recentJankCount = 0.obs;
  final loadProgress = 0.0.obs;
  final contentReady = false.obs;
  final updateBannerVisible = false.obs;
  final refreshCount = 3.obs;

  String get analyticsBackendLabel {
    if (analytics is UmengAnalyticsAdapter) return 'Umeng';
    if (analytics is FirebaseAnalyticsAdapter) return 'Firebase';
    if (analytics is FakeAnalytics) return 'Fake';
    return analytics.runtimeType.toString();
  }

  bool get umengReady =>
      Get.isRegistered<UmengBootstrap>() &&
      Get.find<UmengBootstrap>().isInitialized;

  @override
  void onInit() {
    super.onInit();
    appEvents.screenView('catalog');
    _refreshLastEvent();
    _refreshJankCount();
  }

  void toggleButtonLoading() => buttonLoading.toggle();

  Future<void> logDemo(String action) async {
    await appEvents.catalogDemoTap(action: action);
    _refreshLastEvent();
  }

  Future<void> runLoadProgress() async {
    await logDemo('load_progress');
    loadProgress.value = 0;
    const steps = 20;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (isClosed) return;
      loadProgress.value = i / steps;
    }
  }

  Future<void> toggleContentReveal() async {
    contentReady.toggle();
    await logDemo('load_reveal');
  }

  Future<void> pullRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;
    refreshCount.value++;
    await logDemo('pull_refresh');
  }

  Future<void> showUpdateBanner() async {
    updateBannerVisible.value = true;
    await logDemo('update_banner');
  }

  void dismissUpdateBanner() => updateBannerVisible.value = false;

  Future<void> resetOnboarding() async {
    await OnboardingGate.reset(store);
    await logDemo('reset_onboarding');
  }

  Future<void> showRatingDemo(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await logDemo('rating_prompt_open');
    if (!context.mounted) return;
    final result = await AppRatingPrompt.show(
      context,
      title: l10n.ratingTitle,
      message: l10n.ratingMessage,
      positiveLabel: l10n.ratingPositive,
      negativeLabel: l10n.ratingNegative,
      laterLabel: l10n.ratingLater,
    );
    if (!context.mounted) return;
    switch (result) {
      case AppRatingPromptResult.positive:
        await appEvents.ratingPrompt(action: 'positive');
        _refreshLastEvent();
        if (!context.mounted) return;
        await StoreReviewLauncher.openStore(
          context,
          missingUrlMessage: l10n.ratingStoreUrlMissing,
        );
      case AppRatingPromptResult.negative:
        await appEvents.ratingPrompt(action: 'negative');
        _refreshLastEvent();
        Get.toNamed(AppRoutes.feedback);
      case AppRatingPromptResult.later:
        await appEvents.ratingPrompt(action: 'later');
        _refreshLastEvent();
      case null:
        await appEvents.ratingPrompt(action: 'dismissed');
        _refreshLastEvent();
    }
  }

  Future<void> openFeedbackDemo() async {
    await logDemo('open_feedback');
    Get.toNamed(AppRoutes.feedback);
  }

  Future<void> simulateJank() async {
    final sw = Stopwatch()..start();
    while (sw.elapsedMilliseconds < 50) {
      // Busy-wait to force a long frame / jank sample.
    }
    jankMonitor.recordSyntheticJank(
      buildMs: sw.elapsedMilliseconds,
      rasterMs: 0,
    );
    _refreshJankCount();
    await appEvents.catalogDemoTap(action: 'simulate_jank');
    _refreshLastEvent();
  }

  void _refreshJankCount() {
    recentJankCount.value = jankMonitor.recentJankCount;
  }

  void _refreshLastEvent() {
    if (analytics is FakeAnalytics) {
      final events = (analytics as FakeAnalytics).events;
      if (events.isEmpty) {
        lastEventLabel.value = null;
        return;
      }
      final last = events.last;
      lastEventLabel.value = last.name;
      return;
    }
    lastEventLabel.value = 'event (sent via $analyticsBackendLabel)';
  }
}
