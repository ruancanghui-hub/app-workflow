import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';
import '../../root_shell/widgets/glass_widgets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';
import '../../settings/pages/settings_sheet.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              HealingAssets.background(HealingRootTab.meditation),
              fit: BoxFit.cover,
            ),
            Positioned(
              left: layout.dx(78),
              top: layout.dy(136),
              child: Text(
                '冥想',
                style: HealingDesignSystem.pageTitleDark.copyWith(
                  fontSize: layout.sz(80),
                  letterSpacing: layout.sz(1.6),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(534),
              top: layout.dy(128),
              child: GlassCircleButton(
                asset: HealingAssets.searchButton(HealingRootTab.meditation),
                size: layout.sz(90),
                iconSize: layout.sz(46),
                light: true,
              ),
            ),
        Positioned(
          left: layout.dx(658),
          top: layout.dy(128),
          width: layout.sz(219),
          height: layout.sz(88),
          child: GlassLightPanel(
            borderRadius: layout.sz(999),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: layout.sz(42),
                  width: layout.sz(52),
                  height: layout.sz(52),
                  child: Image.asset(
                    'assets/images/meditation/status/star_status.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  right: layout.sz(6),
                  width: layout.sz(76),
                  height: layout.sz(76),
                  child: GestureDetector(
                    onTap: () => showSettingsSheet(context),
                    child: Image.asset(
                      HealingAssets.profileOrb(HealingRootTab.meditation),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
            Positioned(
              left: layout.dx(94),
              top: layout.dy(319),
              width: layout.sz(757),
              height: layout.sz(319),
              child: GlassLightPanel(
                borderRadius: layout.sz(42),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: layout.dx(95),
              top: layout.dy(428),
              width: layout.sz(148),
              height: layout.sz(154),
              child: Image.asset(
                'assets/images/meditation/feature_art/quote_leaf.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: layout.dx(258),
              top: layout.dy(422),
              width: layout.sz(530),
              child: Text(
                '慢一点，也没关系',
                textAlign: TextAlign.center,
                style: HealingDesignSystem.quoteMain.copyWith(
                  fontSize: layout.sz(48),
                  letterSpacing: layout.sz(1.9),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(424),
              top: layout.dy(506),
              child: Text(
                '今日一句',
                style: HealingDesignSystem.quoteSub.copyWith(
                  fontSize: layout.sz(29),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(87),
              top: layout.dy(721),
              child: SectionTitleRow(
                title: '为心出发',
                decoAsset:
                    'assets/images/meditation/feature_art/section_heading.png',
                titleStyle: HealingDesignSystem.sectionTitleDark.copyWith(
                  fontSize: layout.sz(48),
                ),
                decoHeight: layout.sz(34),
              ),
            ),
            for (final entry in [
              (66.0, 822.0, '新手入门', 'background_beginner_entry.png', _MeditationAction.breath),
              (491.0, 822.0, '睡个好觉', 'background_sleep_well.png', _MeditationAction.player),
              (66.0, 1167.0, '减压放松', 'background_stress_relief.png', _MeditationAction.breath),
              (491.0, 1167.0, '情绪调节', 'background_emotion_regulation.png', _MeditationAction.breath),
            ])
              Positioned(
                left: layout.dx(entry.$1),
                top: layout.dy(entry.$2),
                width: layout.sz(386),
                height: layout.sz(319),
                child: _GridCard(
                  label: entry.$3,
                  imagePath: entry.$4,
                  layout: layout,
                  onTap: () {
                    switch (entry.$5) {
                      case _MeditationAction.breath:
                        openBreath();
                      case _MeditationAction.player:
                        openPlayer('valley_rain');
                    }
                  },
                ),
              ),
            HealingTabBar(
              screenTab: HealingRootTab.meditation,
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

enum _MeditationAction { breath, player }

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.label,
    required this.imagePath,
    required this.layout,
    this.onTap,
  });

  final String label;
  final String imagePath;
  final HealingLayout layout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(layout.sz(32)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x8CFFFFFF)),
          borderRadius: BorderRadius.circular(layout.sz(32)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/meditation/backgrounds/$imagePath',
              fit: BoxFit.cover,
            ),
            Positioned(
              left: layout.sz(34),
              bottom: layout.sz(32),
              child: Text(
                label,
                style: HealingDesignSystem.gridLabel.copyWith(
                  fontSize: layout.sz(31),
                  shadows: const [
                    Shadow(
                      color: Color(0xA6FFFFFF),
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
