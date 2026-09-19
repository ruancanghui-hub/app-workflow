import 'package:get/get.dart';

import '../../core/branding/branding_config.dart';
import '../../core/ops/app_events.dart';
import '../../core/storage/key_value_store.dart';
import 'onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  OnboardingBinding({this.preview = false, this.slideCount = 4});

  final bool preview;
  final int slideCount;

  @override
  void dependencies() {
    if (Get.isRegistered<OnboardingController>()) {
      Get.delete<OnboardingController>(force: true);
    }
    Get.put(
      OnboardingController(
        appEvents: Get.find<AppEvents>(),
        store: Get.find<KeyValueStore>(),
        onboardingVersion: BrandingConfig.fromEnvironment().onboardingVersion,
        preview: preview,
        slideCount: slideCount,
      ),
    );
  }
}
