import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';
import '../../root_shell/root_shell_controller.dart';
import '../../root_shell/widgets/glass_widgets.dart';
import '../../sound_catalog/sound_catalog_controller.dart';
import '../../sound_catalog/widgets/sound_library_sheet.dart';
import 'home_scene_catalog.dart';
import 'home_scene_controller.dart';

enum _HomeCardAction { sleep, focus, breath }

class HomeTabPage extends GetView<HomeSceneController> {
  const HomeTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  static const _homeCards = [
    ('睡眠监测', 'sleep_monitor_icon.png', _HomeCardAction.sleep),
    ('心流专注', 'focus_ring_icon.png', _HomeCardAction.focus),
    ('呼吸练习', 'breath_leaf_icon.png', _HomeCardAction.breath),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        final safeTop = MediaQuery.paddingOf(context).top;
        final headerTop = layout
            .dy(150)
            .clamp(safeTop + layout.dy(8), double.infinity);
        final tabBarTop = layout.tabBarDockedTop(context);
        final cardHeight = layout.sz(286);
        final cardsTop =
            tabBarTop - layout.sz(HealingLayout.cardToTabGap) - cardHeight;
        final sectionTop = cardsTop - layout.sz(HealingLayout.sectionToCardGap);
        final copyTop = layout.height * 0.34;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: HomeSceneCatalog.scenes.length,
                itemBuilder: (context, index) {
                  final scene = HomeSceneCatalog.scenes[index];
                  return GestureDetector(
                    onTap: controller.onSceneTap,
                    child: Image.asset(
                      scene.backgroundAsset,
                      fit: BoxFit.cover,
                      width: layout.width,
                      height: layout.height,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(72),
              right: layout.dx(72),
              top: copyTop,
              child: IgnorePointer(
                child: Obx(() {
                  final scene = controller.currentScene;
                  return AnimatedOpacity(
                    opacity: controller.copyBlockOpacity.value,
                    duration: const Duration(milliseconds: 480),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: controller.titleOpacity.value,
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeOut,
                          child: Text(
                            scene.title,
                            textAlign: TextAlign.center,
                            style: HealingDesignSystem.pageTitle.copyWith(
                              fontSize: layout.sz(56),
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: layout.sz(4),
                            ),
                          ),
                        ),
                        SizedBox(height: layout.sz(28)),
                        Text(
                          controller.typedCopy.value,
                          textAlign: TextAlign.center,
                          style: HealingDesignSystem.subtitle.copyWith(
                            fontSize: layout.sz(32),
                            height: 1.55,
                            letterSpacing: layout.sz(1.2),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              right: layout.dx(28),
              top: layout.height * 0.26,
              bottom: layout.height * 0.38,
              child: Obx(
                () => AnimatedSlide(
                  offset: controller.indicatorsHidden.value
                      ? const Offset(1.6, 0)
                      : Offset.zero,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: controller.indicatorsHidden.value ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 280),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < HomeSceneCatalog.scenes.length; i++)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: layout.sz(5),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: layout.sz(8),
                              height: layout.sz(
                                i == controller.currentIndex.value ? 22 : 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withValues(
                                  alpha: i == controller.currentIndex.value
                                      ? 0.95
                                      : 0.38,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(76),
              top: headerTop,
              right: layout.dx(42),
              child: _HomeHeader(
                layout: layout,
                controller: controller,
                onMuteTap: controller.toggleSound,
              ),
            ),
            Positioned(
              left: layout.dx(72),
              top: sectionTop,
              child: SectionTitleRow(
                title: '当下提议',
                decoAsset:
                    'assets/images/home/feature_art/recommendation_heading.png',
                titleStyle: HealingDesignSystem.sectionTitleLight.copyWith(
                  fontSize: layout.sz(42),
                  height: 1.2,
                ),
                decoHeight: layout.sz(108),
              ),
            ),
            Positioned(
              left: layout.dx(65),
              top: cardsTop,
              width: layout.sz(812),
              height: cardHeight,
              child: Row(
                children: [
                  for (var i = 0; i < _homeCards.length; i++) ...[
                    if (i > 0) SizedBox(width: layout.sz(22)),
                    SizedBox(
                      width: layout.sz(256),
                      height: cardHeight,
                      child: _HomeActionCard(
                        label: _homeCards[i].$1,
                        iconPath:
                            'assets/images/home/feature_art/${_homeCards[i].$2}',
                        iconSize: layout.sz(86),
                        labelSize: layout.sz(34),
                        indicatorWidth: layout.sz(36),
                        radius: layout.sz(36),
                        gap: layout.sz(24),
                        onTap: () => _handleCardTap(context, _homeCards[i].$3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleCardTap(BuildContext context, _HomeCardAction action) {
    switch (action) {
      case _HomeCardAction.sleep:
        openSleepMonitoring();
      case _HomeCardAction.focus:
        Get.find<RootShellController>().requestTab(HealingRootTab.meditation);
      case _HomeCardAction.breath:
        openBreath();
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.layout,
    required this.controller,
    required this.onMuteTap,
  });

  final HealingLayout layout;
  final HomeSceneController controller;
  final VoidCallback onMuteTap;

  @override
  Widget build(BuildContext context) {
    final titleSize = layout.sz(88);
    final subtitleSize = layout.sz(29);
    final pillHeight = layout.sz(120);
    final pillWidth = layout.sz(280);
    final controlIconSize = layout.sz(52);
    final pillPaddingX = layout.sz(36);
    final pillPaddingY = layout.sz(28);
    final dividerGap = layout.sz(4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.greetingTitle.value,
                  style: HealingDesignSystem.pageTitle.copyWith(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                    letterSpacing: titleSize * 0.12,
                  ),
                ),
              ),
              SizedBox(height: layout.sz(22)),
              Obx(
                () => Text(
                  controller.greetingHint.value,
                  style: HealingDesignSystem.subtitle.copyWith(
                    fontSize: subtitleSize,
                    height: 1.5,
                    letterSpacing: subtitleSize * 0.04,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: layout.sz(12)),
        SizedBox(
          width: pillWidth,
          height: pillHeight,
          child: GlassDarkPanel(
            borderRadius: 999,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pillPaddingX,
                vertical: pillPaddingY,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Obx(
                        () => GestureDetector(
                          onTap: onMuteTap,
                          behavior: HitTestBehavior.opaque,
                          child: HugeIcon(
                            icon: controller.soundEnabled.value
                                ? HugeIcons.strokeRoundedVolumeHigh
                                : HugeIcons.strokeRoundedVolumeMute01,
                            size: controlIconSize,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(horizontal: dividerGap),
                    color: const Color(0x2EFFFFFF),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => showSoundLibrarySheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedGridView,
                          size: controlIconSize,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.label,
    required this.iconPath,
    required this.iconSize,
    required this.labelSize,
    required this.indicatorWidth,
    required this.radius,
    required this.gap,
    this.onTap,
  });

  final String label;
  final String iconPath;
  final double iconSize;
  final double labelSize;
  final double indicatorWidth;
  final double radius;
  final double gap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassDarkPanel(
        borderRadius: radius,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(height: gap),
            Text(
              label,
              style: HealingDesignSystem.cardLabel.copyWith(
                fontSize: labelSize,
              ),
            ),
            SizedBox(height: gap),
            Opacity(
              opacity: 0.75,
              child: Image.asset(
                'assets/images/home/status/card_indicator.png',
                width: indicatorWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
