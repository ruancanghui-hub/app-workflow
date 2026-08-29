import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          HealingAssets.background(HealingRootTab.home),
          fit: BoxFit.cover,
        ),
        const Positioned(
          left: 48,
          top: 120,
          child: Text(
            '晚上好',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.12,
            ),
          ),
        ),
        const Positioned(
          left: 48,
          top: 172,
          width: 520,
          child: Text(
            '愿你晚风轻拂，安然入梦。',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xB8FFFFFF),
              height: 1.5,
            ),
          ),
        ),
        Positioned(
          left: 554,
          top: 104,
          width: 210,
          height: 56,
          child: _GlassPill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/home/ui_controls/mute_toggle.png',
                  width: 30,
                  height: 30,
                ),
                Container(
                  width: 1,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: const Color(0x2EFFFFFF),
                ),
                Image.asset(
                  'assets/images/home/ui_controls/grid_menu.png',
                  width: 30,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 822,
          top: 102,
          width: 62,
          height: 62,
          child: Image.asset(HealingAssets.profileOrb(HealingRootTab.home)),
        ),
        const Positioned(
          left: 48,
          top: 368,
          child: Text(
            '此刻建议',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        for (final entry in [
          (44.0, 420.0, '睡眠监测', 'sleep_monitor_icon.png'),
          (326.0, 420.0, '心流专注', 'focus_ring_icon.png'),
          (608.0, 420.0, '呼吸练习', 'breath_leaf_icon.png'),
        ])
          Positioned(
            left: entry.$1,
            top: entry.$2,
            width: 264,
            height: 264,
            child: _HomeActionCard(
              label: entry.$3,
              iconPath: 'assets/images/home/feature_art/${entry.$4}',
            ),
          ),
        HealingTabBar(
          screenTab: HealingRootTab.home,
          activeTab: activeTab,
          onTabSelected: onTabSelected,
        ),
      ],
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.label,
    required this.iconPath,
  });

  final String label;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x85161C24),
            border: Border.all(color: const Color(0x24FFFFFF)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, width: 72, height: 72),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Image.asset(
                'assets/images/home/status/card_indicator.png',
                width: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x85161C24),
            border: Border.all(color: const Color(0x24FFFFFF)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: child,
        ),
      ),
    );
  }
}
