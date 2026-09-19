import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/branding/onboarding_gate.dart';
import '../../core/ops/app_events.dart';
import '../../core/storage/key_value_store.dart';

class OnboardingController extends GetxController {
  OnboardingController({
    required this.appEvents,
    required this.store,
    required this.onboardingVersion,
    required this.preview,
    required this.slideCount,
  });

  final AppEvents appEvents;
  final KeyValueStore store;
  final String onboardingVersion;
  final bool preview;
  final int slideCount;

  final pageIndex = 0.obs;
  late final PageController pageController;

  bool get isLastPage => pageIndex.value >= slideCount - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    appEvents.screenView('onboarding');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) => pageIndex.value = index;

  Future<void> next() async {
    if (isLastPage) {
      await finish();
      return;
    }
    await pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> skip() => finish();

  Future<void> finish() async {
    if (!preview) {
      await OnboardingGate.markSeen(store, onboardingVersion);
      await appEvents.onboardingComplete(version: onboardingVersion);
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    Get.back();
  }
}
