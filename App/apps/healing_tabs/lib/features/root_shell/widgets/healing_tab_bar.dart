import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import 'animated_tab_layer.dart';

class HealingTabBar extends StatelessWidget {
  const HealingTabBar({
    required this.screenTab,
    required this.activeTab,
    required this.onTabSelected,
    this.layout = HealingTabBarLayout.designCanvas,
    super.key,
  });

  final HealingRootTab screenTab;
  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;
  final HealingTabBarLayout layout;

  @override
  Widget build(BuildContext context) {
    final bar = HealingTabBarShell(
      screenTab: screenTab,
      activeTab: activeTab,
      onTabSelected: onTabSelected,
      scaledSizes: layout == HealingTabBarLayout.docked,
    );

    if (layout == HealingTabBarLayout.docked) {
      final metrics = HealingLayout.of(context);
      return AnimatedPositioned(
        duration: AnimatedTabLayer.duration,
        curve: AnimatedTabLayer.curve,
        left: metrics.dx(_frame.left),
        top: metrics.tabBarDockedTop(context),
        width: metrics.sz(_frame.width),
        height: metrics.tabBarDockedHeight,
        child: bar,
      );
    }

    return Positioned(left: 40, top: 1502, width: 861, height: 88, child: bar);
  }

  _TabBarFrame get _frame => switch (screenTab) {
    HealingRootTab.meditation => const _TabBarFrame(left: 56, width: 829),
    HealingRootTab.sleep => const _TabBarFrame(left: 32, width: 877),
    HealingRootTab.home ||
    HealingRootTab.device => const _TabBarFrame(left: 20, width: 901),
  };
}

class _TabBarFrame {
  const _TabBarFrame({required this.left, required this.width});

  final double left;
  final double width;
}

enum HealingTabBarLayout { designCanvas, docked }

class _TabMetrics {
  const _TabMetrics({
    required this.iconSize,
    required this.glowSize,
    required this.slotSize,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.radius,
  });

  final double iconSize;
  final double glowSize;
  final double slotSize;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double radius;
}

class HealingTabBarShell extends StatelessWidget {
  const HealingTabBarShell({
    required this.screenTab,
    required this.activeTab,
    required this.onTabSelected,
    this.scaledSizes = false,
    super.key,
  });

  final HealingRootTab screenTab;
  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;
  final bool scaledSizes;

  _TabMetrics _resolveMetrics(HealingLayout metrics, Size bounds) {
    if (scaledSizes) {
      final iconSize = metrics.sz(116);
      final glowSize = metrics.sz(150);
      final slotSize = metrics.sz(160);
      return _TabMetrics(
        iconSize: iconSize,
        glowSize: glowSize,
        slotSize: slotSize,
        horizontalPadding: metrics.sz(28),
        topPadding: metrics.sz(18),
        bottomPadding: metrics.sz(14),
        radius: metrics.sz(64),
      );
    }

    final radius = metrics.sz(30);
    final horizontalPadding = metrics.sz(8);
    final topPadding = metrics.sz(10);
    final bottomPadding = metrics.sz(8);

    final targetIcon = metrics.sz(72);
    final targetGlow = metrics.sz(88);
    final targetSlot = math.max(targetIcon, targetGlow);

    final contentHeight = math.max(
      0,
      bounds.height - topPadding - bottomPadding - 2,
    );
    final contentWidth = math.max(0, bounds.width - horizontalPadding * 2);
    final tabWidth = contentWidth / HealingRootTab.ordered.length;

    final heightScale = targetSlot > 0 ? contentHeight / targetSlot : 1.0;
    final widthScale = tabWidth > 0 ? tabWidth / targetSlot : 1.0;
    final fitScale = math.min(1.0, math.min(heightScale, widthScale)) * 0.96;

    return _TabMetrics(
      iconSize: targetIcon * fitScale,
      glowSize: targetGlow * fitScale,
      slotSize: targetSlot * fitScale,
      horizontalPadding: horizontalPadding,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      radius: radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = screenTab == HealingRootTab.meditation;
    final metrics = HealingLayout.of(context);
    final activeIndex = HealingRootTab.ordered.indexOf(activeTab);
    final accent = HealingDesignSystem.navAccent(activeTab);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabMetrics = _resolveMetrics(metrics, constraints.biggest);

        return ClipRRect(
          borderRadius: BorderRadius.circular(tabMetrics.radius),
          clipBehavior: Clip.hardEdge,
          child: BackdropFilter(
            filter: HealingDesignSystem.glassBlur,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isLight
                    ? HealingDesignSystem.glassLightFill
                    : HealingDesignSystem.glassDarkFill,
                border: Border.all(
                  color: isLight
                      ? HealingDesignSystem.glassLightBorder
                      : HealingDesignSystem.glassDarkBorder,
                ),
                borderRadius: BorderRadius.circular(tabMetrics.radius),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tabMetrics.horizontalPadding,
                  tabMetrics.topPadding,
                  tabMetrics.horizontalPadding,
                  tabMetrics.bottomPadding,
                ),
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final contentWidth = innerConstraints.maxWidth;
                      final tabWidth =
                          contentWidth / HealingRootTab.ordered.length;
                      final glowLeft = activeIndex * tabWidth +
                          (tabWidth - tabMetrics.glowSize) / 2;
                      final glowTop =
                          (innerConstraints.maxHeight - tabMetrics.glowSize) /
                              2;

                      return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          AnimatedPositioned(
                            duration: AnimatedTabLayer.duration,
                            curve: AnimatedTabLayer.curve,
                            left: glowLeft,
                            top: glowTop,
                            width: tabMetrics.glowSize,
                            height: tabMetrics.glowSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withValues(
                                  alpha: isLight ? 0.38 : 0.32,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (final tab in HealingRootTab.ordered)
                                Expanded(
                                  child: Center(
                                    child: _TabItem(
                                      label: tab.label,
                                      iconPath:
                                          HealingAssets.navIcon(screenTab, tab),
                                      selected: tab == activeTab,
                                      iconSize: tabMetrics.iconSize *
                                          HealingAssets.navIconVisualScale(tab),
                                      slotSize: tabMetrics.slotSize,
                                      onTap: () => onTabSelected(tab),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.iconPath,
    required this.selected,
    required this.iconSize,
    required this.slotSize,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool selected;
  final double iconSize;
  final double slotSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label，${selected ? '已选中' : '未选中'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: slotSize,
          height: slotSize,
          child: Center(
            child: Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
