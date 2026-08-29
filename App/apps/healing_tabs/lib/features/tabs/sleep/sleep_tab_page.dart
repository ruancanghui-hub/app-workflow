import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';

class SleepTabPage extends StatelessWidget {
  const SleepTabPage({
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
          HealingAssets.background(HealingRootTab.sleep),
          fit: BoxFit.cover,
        ),
        const Positioned(
          left: 48,
          top: 120,
          child: Text(
            '睡眠',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        _HeaderIcon(left: 668, top: 106, asset: HealingAssets.searchButton(HealingRootTab.sleep)),
        _HeaderIcon(left: 736, top: 106, asset: HealingAssets.addButton(HealingRootTab.sleep)),
        Positioned(
          left: 808,
          top: 104,
          width: 62,
          height: 62,
          child: Image.asset(HealingAssets.profileOrb(HealingRootTab.sleep)),
        ),
        const Positioned(
          left: 48,
          top: 232,
          child: Text('今晚好眠', style: TextStyle(fontSize: 14, color: Color(0xB3FFFFFF))),
        ),
        const Positioned(
          left: 48,
          top: 274,
          child: Text(
            '月光入梦',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w500,
              letterSpacing: 3.5,
              color: Colors.white,
            ),
          ),
        ),
        const Positioned(
          left: 48,
          top: 352,
          child: Text('睡前冥想 · 20 分钟', style: TextStyle(fontSize: 15, color: Color(0xFF9AA0B9))),
        ),
        Positioned(
          left: 50,
          top: 396,
          width: 100,
          height: 100,
          child: Image.asset(HealingAssets.playButton(HealingRootTab.sleep)),
        ),
        Positioned(
          left: 40,
          top: 672,
          width: 861,
          height: 244,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x85161C24),
                  border: Border.all(color: const Color(0x24FFFFFF)),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    for (final item in [
                      ('睡眠故事', 'sleep_story_icon.png'),
                      ('呼吸', 'breath_icon.png'),
                      ('放松', 'relax_leaf_icon.png'),
                    ])
                      Expanded(
                        child: _FeatureTile(
                          label: item.$1,
                          iconPath: 'assets/images/sleep/feature_art/${item.$2}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        HealingTabBar(
          screenTab: HealingRootTab.sleep,
          activeTab: activeTab,
          onTabSelected: onTabSelected,
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.left,
    required this.top,
    required this.asset,
  });

  final double left;
  final double top;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: 56,
      height: 56,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0x85161C24),
              shape: BoxShape.circle,
            ),
            child: Center(child: Image.asset(asset, width: 28, height: 28)),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.label,
    required this.iconPath,
  });

  final String label;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, width: 64, height: 64),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(height: 8),
        Image.asset(
          'assets/images/sleep/status/card_indicator.png',
          width: 40,
        ),
      ],
    );
  }
}
