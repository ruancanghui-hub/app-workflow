import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';

class HealingTabBar extends StatelessWidget {
  const HealingTabBar({
    required this.screenTab,
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab screenTab;
  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final isLight = screenTab == HealingRootTab.meditation;
    return Positioned(
      left: 40,
      top: 1502,
      width: 861,
      height: 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0x9EFFFFFF)
                  : const Color(0x85161C24),
              border: Border.all(
                color: isLight
                    ? const Color(0xB8FFFFFF)
                    : const Color(0x24FFFFFF),
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                for (final tab in HealingRootTab.ordered)
                  Expanded(
                    child: _TabItem(
                      label: tab.label,
                      iconPath: HealingAssets.navIcon(screenTab, tab),
                      selected: tab == activeTab,
                      isLight: isLight,
                      onTap: () => onTabSelected(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.iconPath,
    required this.selected,
    required this.isLight,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool selected;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = selected
        ? (isLight ? const Color(0xFFE6A23C) : Colors.white)
        : (isLight
            ? const Color(0x9E2C3338)
            : const Color(0xB3FFFFFF));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                opacity: selected ? null : const AlwaysStoppedAnimation(0.5),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: labelColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
