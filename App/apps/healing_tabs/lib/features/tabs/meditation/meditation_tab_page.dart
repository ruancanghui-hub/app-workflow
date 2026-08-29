import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';

class MeditationTabPage extends StatelessWidget {
  const MeditationTabPage({
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
          'assets/images/meditation/backgrounds/background_meditation.png',
          fit: BoxFit.cover,
        ),
        const Positioned(
          left: 48,
          top: 120,
          child: Text(
            '冥想',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3338),
            ),
          ),
        ),
        Positioned(
          left: 136,
          top: 126,
          width: 50,
          height: 50,
          child: _LightIconButton(
            asset: HealingAssets.searchButton(HealingRootTab.meditation),
          ),
        ),
        Positioned(
          left: 652,
          top: 106,
          width: 154,
          height: 56,
          child: Image.asset(
            'assets/images/meditation/status/star_status.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 40,
          top: 190,
          width: 861,
          height: 156,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x9EFFFFFF),
                  border: Border.all(color: const Color(0xB8FFFFFF)),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 56,
          top: 206,
          width: 84,
          height: 122,
          child: Image.asset('assets/images/meditation/feature_art/quote_leaf.png'),
        ),
        const Positioned(
          left: 160,
          top: 234,
          width: 640,
          child: Text(
            '慢一点，也没关系',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3338),
            ),
          ),
        ),
        const Positioned(
          left: 160,
          top: 276,
          child: Text(
            '今日一句',
            style: TextStyle(fontSize: 13, color: Color(0x9E2C3338)),
          ),
        ),
        const Positioned(
          left: 48,
          top: 372,
          child: Text(
            '为心出发',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3338),
            ),
          ),
        ),
        for (final entry in [
          (44.0, 418.0, '新手入门', 'background_beginner_entry.png'),
          (478.0, 418.0, '睡个好觉', 'background_sleep_well.png'),
          (44.0, 692.0, '减压放松', 'background_stress_relief.png'),
          (478.0, 692.0, '情绪调节', 'background_emotion_regulation.png'),
        ])
          Positioned(
            left: entry.$1,
            top: entry.$2,
            width: 418,
            height: 258,
            child: _GridCard(label: entry.$3, imagePath: entry.$4),
          ),
        HealingTabBar(
          screenTab: HealingRootTab.meditation,
          activeTab: activeTab,
          onTabSelected: onTabSelected,
        ),
      ],
    );
  }
}

class _LightIconButton extends StatelessWidget {
  const _LightIconButton({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x9EFFFFFF),
            shape: BoxShape.circle,
          ),
          child: Center(child: Image.asset(asset, width: 24, height: 24)),
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.label,
    required this.imagePath,
  });

  final String label;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/meditation/backgrounds/$imagePath',
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3338),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
