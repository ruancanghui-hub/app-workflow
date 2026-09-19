import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';
import 'catalog_controller.dart';

class CatalogPage extends GetView<CatalogController> {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = FTheme.of(context);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.catalogTitle),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.only(bottom: tokens.spaceLg),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceMd,
              tokens.spaceSm,
              tokens.spaceMd,
              0,
            ),
            child: Text(
              l10n.catalogIntro,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),

          // —— Splash & Onboarding ——
          AppSectionHeader(l10n.catalogSectionSplash),
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.catalogPreviewSplash),
                onPress: () {
                  controller.logDemo('preview_splash');
                  Get.toNamed(AppRoutes.catalogSplashPreview);
                },
              ),
              FTile(
                title: Text(l10n.catalogPreviewOnboarding),
                onPress: () {
                  controller.logDemo('preview_onboarding');
                  Get.toNamed(AppRoutes.catalogOnboarding);
                },
              ),
              FTile(
                title: Text(l10n.catalogResetOnboarding),
                onPress: () async {
                  await controller.resetOnboarding();
                  if (!context.mounted) return;
                  AppToast.success(context, l10n.catalogResetOnboardingDone);
                },
              ),
            ],
          ),

          // —— Rating & Feedback ——
          AppSectionHeader(l10n.catalogSectionRating),
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.catalogShowRating),
                subtitle: Text(l10n.catalogShowRatingHint),
                onPress: () => controller.showRatingDemo(context),
              ),
              FTile(
                title: Text(l10n.catalogOpenFeedback),
                onPress: controller.openFeedbackDemo,
              ),
            ],
          ),

          // —— Buttons ——
          AppSectionHeader(l10n.catalogSectionButtons),
          FCard(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.catalogButtonsHint,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => controller.logDemo('button_primary'),
                        child: const Text('Primary'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.secondary,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => controller.logDemo('button_secondary'),
                        child: const Text('Secondary'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.destructive,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => controller.logDemo('button_destructive'),
                        child: const Text('Destructive'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.outline,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => controller.logDemo('button_outline'),
                        child: const Text('Outline'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.ghost,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => controller.logDemo('button_ghost'),
                        child: const Text('Ghost'),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Obx(
                    () => AppButton(
                      loading: controller.buttonLoading.value,
                      onPress: controller.toggleButtonLoading,
                      child: Text(
                        controller.buttonLoading.value
                            ? 'Loading…'
                            : 'Toggle loading',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // —— Dialogs ——
          AppSectionHeader(l10n.catalogSectionDialogs),
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.catalogDialogConfirm),
                onPress: () async {
                  await controller.logDemo('dialog_confirm');
                  if (!context.mounted) return;
                  final ok = await AppDialog.showConfirm(
                    context,
                    title: 'Confirm demo',
                    message: 'AppDialog.showConfirm returns true / false.',
                  );
                  if (!context.mounted) return;
                  AppToast.info(
                    context,
                    ok == true ? 'Confirmed' : 'Cancelled',
                  );
                },
              ),
              FTile(
                title: Text(l10n.catalogDialogAlert),
                onPress: () async {
                  await controller.logDemo('dialog_alert');
                  if (!context.mounted) return;
                  await AppDialog.showAlert(
                    context,
                    title: 'Alert demo',
                    message: 'Single-action alert via AppDialog.showAlert.',
                  );
                },
              ),
            ],
          ),

          // —— Feedback ——
          AppSectionHeader(l10n.catalogSectionFeedback),
          FTileGroup(
            children: [
              FTile(
                title: const Text('Toast info'),
                onPress: () {
                  controller.logDemo('toast_info');
                  AppToast.info(context, 'Info toast');
                },
              ),
              FTile(
                title: const Text('Toast success'),
                onPress: () {
                  controller.logDemo('toast_success');
                  AppToast.success(context, 'Success toast');
                },
              ),
              FTile(
                title: const Text('Toast error'),
                onPress: () {
                  controller.logDemo('toast_error');
                  AppToast.error(context, 'Error toast');
                },
              ),
              FTile(
                title: Text(l10n.catalogFeedbackOverlay),
                onPress: () async {
                  await controller.logDemo('loading_overlay');
                  if (!context.mounted) return;
                  await AppLoadingOverlay.during(
                    context,
                    () => Future<void>.delayed(const Duration(milliseconds: 600)),
                    message: 'Working…',
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceMd,
              tokens.spaceSm,
              tokens.spaceMd,
              0,
            ),
            child: FCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: const AppLoading.inline(label: 'AppLoading.inline'),
              ),
            ),
          ),

          // —— Placeholders ——
          AppSectionHeader(l10n.catalogSectionPlaceholders),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FCard(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceMd),
                    child: AppSkeleton.list(lines: 3),
                  ),
                ),
                SizedBox(height: tokens.spaceSm),
                FCard(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceMd),
                    child: AppSkeleton.card(),
                  ),
                ),
                SizedBox(height: tokens.spaceSm),
                FCard(
                  child: AppEmpty(
                    title: l10n.catalogEmptyTitle,
                    description: l10n.catalogEmptyDescription,
                  ),
                ),
              ],
            ),
          ),

          // —— Motion ——
          AppSectionHeader(l10n.catalogSectionMotion),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: AppAppear(
              child: FCard(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.catalogMotionAppearHint,
                        style: theme.typography.body.sm,
                      ),
                      SizedBox(height: tokens.spaceMd),
                      AppButton(
                        onPress: () {
                          controller.logDemo('transition_shared_axis');
                          Get.toNamed(AppRoutes.catalogSharedAxis);
                        },
                        child: Text(l10n.catalogMotionSharedAxis),
                      ),
                      SizedBox(height: tokens.spaceSm),
                      AppButton(
                        variant: AppButtonVariant.secondary,
                        onPress: () {
                          controller.logDemo('transition_fade_through');
                          Get.toNamed(AppRoutes.catalogFadeThrough);
                        },
                        child: Text(l10n.catalogMotionFadeThrough),
                      ),
                      SizedBox(height: tokens.spaceSm),
                      AppButton(
                        variant: AppButtonVariant.outline,
                        onPress: () {
                          controller.logDemo('transition_fade_scale');
                          Get.toNamed(AppRoutes.catalogFadeScale);
                        },
                        child: Text(l10n.catalogMotionFadeScale),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // —— Loading views ——
          AppSectionHeader(l10n.catalogSectionLoadingMotion),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: FCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.catalogMotionLoadingHint,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FCircularProgress(),
                        FCircularProgress.loader(),
                        FCircularProgress.pinwheel(),
                      ],
                    ),
                    SizedBox(height: tokens.spaceMd),
                    const FProgress(),
                    SizedBox(height: tokens.spaceMd),
                    Obx(
                      () => FDeterminateProgress(
                        value: controller.loadProgress.value,
                      ),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    AppButton(
                      onPress: controller.runLoadProgress,
                      child: Text(l10n.catalogMotionRunProgress),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    Obx(
                      () => PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (child, animation, secondaryAnimation) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                        child: controller.contentReady.value
                            ? KeyedSubtree(
                                key: const ValueKey('catalog-loaded'),
                                child: Text(
                                  l10n.catalogMotionLoadedContent,
                                  style: theme.typography.body.sm,
                                ),
                              )
                            : AppSkeleton.list(
                                key: const ValueKey('catalog-skeleton'),
                                lines: 3,
                              ),
                      ),
                    ),
                    SizedBox(height: tokens.spaceSm),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      onPress: controller.toggleContentReveal,
                      child: Text(l10n.catalogMotionReveal),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // —— Pull to refresh ——
          AppSectionHeader(l10n.catalogSectionPullRefresh),
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.catalogMotionPullRefresh),
                subtitle: Text(l10n.catalogMotionPullRefreshHint),
                onPress: () {
                  controller.logDemo('open_pull_refresh');
                  Get.toNamed(AppRoutes.catalogRefresh);
                },
              ),
            ],
          ),

          // —— Accordion ——
          AppSectionHeader(l10n.catalogSectionAccordion),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: FCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.catalogAccordionHint,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    SizedBox(height: tokens.spaceSm),
                    FAccordion(
                      children: [
                        FAccordionItem(
                          initiallyExpanded: true,
                          title: Text(l10n.catalogAccordionItem1),
                          child: Text(l10n.catalogAccordionBody1),
                        ),
                        FAccordionItem(
                          title: Text(l10n.catalogAccordionItem2),
                          child: Text(l10n.catalogAccordionBody2),
                        ),
                        FAccordionItem(
                          title: Text(l10n.catalogAccordionItem3),
                          child: Text(l10n.catalogAccordionBody3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // —— Update prompt ——
          AppSectionHeader(l10n.catalogSectionUpdatePrompt),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  if (!controller.updateBannerVisible.value) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: tokens.spaceSm),
                    child: AppAppear(
                      child: FAlert(
                        title: Text(l10n.catalogUpdateBannerTitle),
                        subtitle: Text(l10n.catalogUpdateBannerSubtitle),
                      ),
                    ),
                  );
                }),
                AppButton(
                  onPress: () async {
                    await controller.logDemo('update_sheet');
                    if (!context.mounted) return;
                    final updated = await AppUpdatePrompt.show(
                      context,
                      title: l10n.catalogUpdateTitle,
                      version: l10n.catalogUpdateVersion,
                      notes: l10n.catalogUpdateNotes,
                      updateLabel: l10n.catalogUpdateAction,
                      laterLabel: l10n.catalogUpdateLater,
                    );
                    if (!context.mounted || updated != true) return;
                    AppToast.success(context, l10n.catalogUpdateStarted);
                  },
                  child: Text(l10n.catalogUpdateShowSheet),
                ),
                SizedBox(height: tokens.spaceSm),
                Obx(
                  () => AppButton(
                    variant: AppButtonVariant.secondary,
                    onPress: controller.updateBannerVisible.value
                        ? controller.dismissUpdateBanner
                        : controller.showUpdateBanner,
                    child: Text(
                      controller.updateBannerVisible.value
                          ? l10n.catalogUpdateDismissBanner
                          : l10n.catalogUpdateShowBanner,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // —— Analytics ——
          AppSectionHeader(l10n.catalogSectionAnalytics),
          Obx(
            () => FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.catalogAnalyticsBackend),
                  subtitle: Text(controller.analyticsBackendLabel),
                ),
                FTile(
                  title: Text(l10n.catalogAnalyticsFire),
                  onPress: () => controller.logDemo('manual_fire'),
                ),
                FTile(
                  title: Text(l10n.catalogAnalyticsLast),
                  subtitle: Text(
                    controller.lastEventLabel.value ?? '—',
                  ),
                ),
              ],
            ),
          ),

          // —— Monitoring ——
          AppSectionHeader(l10n.catalogSectionMonitoring),
          Obx(
            () => FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.catalogMonitoringJankCount),
                  subtitle: Text('${controller.recentJankCount.value}'),
                ),
                FTile(
                  title: Text(l10n.catalogMonitoringSimulate),
                  onPress: controller.simulateJank,
                ),
                FTile(
                  title: Text(l10n.catalogMonitoringDiagnostics),
                  onPress: () {
                    controller.logDemo('open_diagnostics');
                    Get.toNamed(
                      AppRoutes.diagnostics,
                      parameters: {'source': 'catalog'},
                    );
                  },
                ),
              ],
            ),
          ),

          // —— Lottie / Rive ——
          AppSectionHeader(l10n.catalogSectionMotionAssets),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
            child: FCard(
              child: AppEmpty(
                title: l10n.catalogMotionAssetsTitle,
                description: l10n.catalogMotionAssetsDescription,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
