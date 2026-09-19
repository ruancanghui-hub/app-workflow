import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_controller.dart';
import 'onboarding_slides.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = FTheme.of(context);
    final slides = onboardingSlidesFor(l10n);

    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spaceMd,
            tokens.spaceMd,
            tokens.spaceMd,
            tokens.spaceLg,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: slides.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: tokens.spaceSm),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            slide.icon,
                            size: 72,
                            color: theme.colors.primary,
                          ),
                          SizedBox(height: tokens.spaceLg),
                          Text(
                            slide.title,
                            style: theme.typography.display.lg.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: tokens.spaceMd),
                          Text(
                            slide.body,
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Obx(() {
                final current = controller.pageIndex.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < slides.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == current ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == current
                              ? theme.colors.primary
                              : theme.colors.mutedForeground
                                  .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              SizedBox(height: tokens.spaceLg),
              Obx(() {
                final last = controller.isLastPage;
                return Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.ghost,
                        onPress: controller.skip,
                        child: Text(l10n.onboardingSkip),
                      ),
                    ),
                    SizedBox(width: tokens.spaceSm),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        onPress: controller.next,
                        child: Text(
                          last
                              ? l10n.onboardingGetStarted
                              : l10n.onboardingNext,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
