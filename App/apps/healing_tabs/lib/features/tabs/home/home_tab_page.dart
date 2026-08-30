import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../root_shell/widgets/glass_widgets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  static const _homeCards = [
    ('睡眠监测', 'sleep_monitor_icon.png'),
    ('心流专注', 'focus_ring_icon.png'),
    ('呼吸练习', 'breath_leaf_icon.png'),
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
        final tabBarTop = layout.tabBarTop(context, HealingRootTab.home);
        final cardHeight = layout.sz(286);
        final cardsTop =
            tabBarTop - layout.sz(HealingLayout.cardToTabGap) - cardHeight;
        final sectionTop = cardsTop - layout.sz(HealingLayout.sectionToCardGap);

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              HealingAssets.background(HealingRootTab.home),
              fit: BoxFit.cover,
              width: layout.width,
              height: layout.height,
            ),
            Positioned(
              left: layout.dx(76),
              top: headerTop,
              right: layout.dx(42),
              child: _HomeHeader(layout: layout),
            ),
            Positioned(
              left: layout.dx(72),
              top: sectionTop,
              child: SectionTitleRow(
                title: '此刻建议',
                decoAsset:
                    'assets/images/home/feature_art/recommendation_heading.png',
                titleStyle: HealingDesignSystem.sectionTitleLight.copyWith(
                  fontSize: layout.sz(42),
                  height: 1.2,
                ),
                decoHeight: layout.sz(32),
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
                      ),
                    ),
                  ],
                ],
              ),
            ),
            HealingTabBar(
              screenTab: HealingRootTab.home,
              activeTab: activeTab,
              onTabSelected: onTabSelected,
              layout: HealingTabBarLayout.docked,
            ),
          ],
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final titleSize = layout.sz(88);
    final subtitleSize = layout.sz(29);
    final pillHeight = layout.sz(92);
    final pillWidth = layout.sz(234);
    final profileSize = layout.sz(124);
    final controlIconSize = layout.sz(188);
    final pillPaddingX = layout.sz(16);
    final dividerGap = layout.sz(12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '晚上好',
                style: HealingDesignSystem.pageTitle.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                  letterSpacing: titleSize * 0.12,
                ),
              ),
              SizedBox(height: layout.sz(22)),
              Text(
                '愿你晚风轻拂，安然入梦。',
                style: HealingDesignSystem.subtitle.copyWith(
                  fontSize: subtitleSize,
                  height: 1.5,
                  letterSpacing: subtitleSize * 0.04,
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
              padding: EdgeInsets.symmetric(horizontal: pillPaddingX),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dividerWidth = 1 + dividerGap * 2;
                  final maxIconSize = math.min(
                    controlIconSize,
                    math.min(
                      (constraints.maxWidth - dividerWidth) / 2,
                      constraints.maxHeight * 0.72,
                    ),
                  );
                  final dividerHeight = math.min(
                    layout.sz(52),
                    constraints.maxHeight * 0.56,
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/home/ui_controls/mute_toggle.png',
                        width: maxIconSize,
                        height: maxIconSize,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        width: 1,
                        height: dividerHeight,
                        margin: EdgeInsets.symmetric(horizontal: dividerGap),
                        color: const Color(0x2EFFFFFF),
                      ),
                      Image.asset(
                        'assets/images/home/ui_controls/grid_menu.png',
                        width: maxIconSize,
                        height: maxIconSize,
                        fit: BoxFit.contain,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(width: layout.sz(12)),
        SizedBox(
          width: profileSize,
          height: profileSize,
          child: Image.asset(
            HealingAssets.profileOrb(HealingRootTab.home),
            width: profileSize,
            height: profileSize,
            fit: BoxFit.contain,
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
  });

  final String label;
  final String iconPath;
  final double iconSize;
  final double labelSize;
  final double indicatorWidth;
  final double radius;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return GlassDarkPanel(
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
            style: HealingDesignSystem.cardLabel.copyWith(fontSize: labelSize),
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
    );
  }
}
