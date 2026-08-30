import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';

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
      return Positioned(
        left: metrics.dx(_frame.left),
        top: metrics.tabBarTop(context, screenTab),
        width: metrics.sz(_frame.width),
        height: metrics.tabBarHeight(screenTab),
        child: bar,
      );
    }

    return Positioned(left: 40, top: 1502, width: 861, height: 88, child: bar);
  }

  _TabBarFrame get _frame => switch (screenTab) {
    HealingRootTab.meditation => const _TabBarFrame(left: 56, width: 829),
    HealingRootTab.sleep => const _TabBarFrame(left: 32, width: 877),
    HealingRootTab.home ||
    HealingRootTab.sound => const _TabBarFrame(left: 20, width: 901),
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
    required this.labelSize,
    required this.iconLabelGap,
    required this.glowSize,
    required this.slotSize,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.radius,
  });

  final double iconSize;
  final double labelSize;
  final double iconLabelGap;
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
    final radius = scaledSizes ? metrics.sz(64) : metrics.sz(30);
    final horizontalPadding = scaledSizes ? metrics.sz(28) : metrics.sz(8);
    final topPadding = scaledSizes ? metrics.sz(18) : metrics.sz(10);
    final bottomPadding = scaledSizes ? metrics.sz(14) : metrics.sz(8);

    final targetIcon = scaledSizes ? metrics.sz(116) : metrics.sz(72);
    final targetGlow = scaledSizes ? metrics.sz(168) : metrics.sz(88);
    final targetSlot = math.max(targetIcon, targetGlow);
    final targetGap = scaledSizes ? metrics.sz(12) : metrics.sz(6);
    final targetLabel = scaledSizes ? metrics.sz(30) : metrics.sz(12);

    final contentHeight = math.max(
      0,
      bounds.height - topPadding - bottomPadding - 2,
    );
    final contentWidth = math.max(0, bounds.width - horizontalPadding * 2);
    final tabWidth = contentWidth / HealingRootTab.ordered.length;

    final naturalHeight = targetSlot + targetGap + targetLabel;
    final heightScale = naturalHeight > 0 ? contentHeight / naturalHeight : 1.0;
    final widthScale = tabWidth > 0 ? tabWidth / targetSlot : 1.0;
    final fitScale = math.min(1.0, math.min(heightScale, widthScale)) * 0.96;

    return _TabMetrics(
      iconSize: targetIcon * fitScale,
      labelSize: targetLabel * fitScale,
      iconLabelGap: targetGap * fitScale,
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (final tab in HealingRootTab.ordered)
                        Expanded(
                          child: _TabItem(
                            label: tab.label,
                            iconPath: HealingAssets.navIcon(screenTab, tab),
                            selected: tab == activeTab,
                            isLight: isLight,
                            accent: HealingDesignSystem.navAccent(tab),
                            iconSize: tabMetrics.iconSize,
                            labelSize: tabMetrics.labelSize,
                            iconLabelGap: tabMetrics.iconLabelGap,
                            glowSize: tabMetrics.glowSize,
                            slotSize: tabMetrics.slotSize,
                            onTap: () => onTabSelected(tab),
                          ),
                        ),
                    ],
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
    required this.isLight,
    required this.accent,
    required this.iconSize,
    required this.labelSize,
    required this.iconLabelGap,
    required this.glowSize,
    required this.slotSize,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool selected;
  final bool isLight;
  final Color accent;
  final double iconSize;
  final double labelSize;
  final double iconLabelGap;
  final double glowSize;
  final double slotSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = selected
        ? (isLight ? accent : HealingDesignSystem.textLight)
        : (isLight
              ? HealingDesignSystem.textDarkMuted
              : HealingDesignSystem.textLightMuted);

    return Semantics(
      button: true,
      selected: selected,
      label: '$label，${selected ? '已选中' : '未选中'}',
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: slotSize,
              height: slotSize,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                children: [
                  if (selected)
                    Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: isLight ? 0.38 : 0.32),
                      ),
                    ),
                  Image.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    opacity: selected
                        ? null
                        : const AlwaysStoppedAnimation(0.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: iconLabelGap),
            Text(
              label,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: HealingDesignSystem.navLabel.copyWith(
                fontSize: labelSize,
                height: 1.0,
                color: labelColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
    );
  }
}
