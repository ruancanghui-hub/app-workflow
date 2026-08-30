import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';
import '../../root_shell/widgets/glass_widgets.dart';
import '../../settings/pages/settings_sheet.dart';
import '../../sleep_session/widgets/sleep_history_sheet.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              HealingAssets.background(HealingRootTab.sleep),
              fit: BoxFit.cover,
            ),
            Positioned(
              left: layout.dx(77),
              top: layout.dy(154),
              child: Text(
                '睡眠',
                style: HealingDesignSystem.pageTitle.copyWith(
                  fontSize: layout.sz(82),
                  letterSpacing: layout.sz(1.6),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(522),
              top: layout.dy(153),
              child: GlassCircleButton(
                asset: HealingAssets.searchButton(HealingRootTab.sleep),
                size: layout.sz(90),
                iconSize: layout.sz(46),
              ),
            ),
            Positioned(
              left: layout.dx(634),
              top: layout.dy(153),
              width: layout.sz(122),
              height: layout.sz(90),
              child: GlassDarkPanel(
                borderRadius: layout.sz(999),
                child: Center(
                  child: Image.asset(
                    HealingAssets.addButton(HealingRootTab.sleep),
                    width: layout.sz(54),
                    height: layout.sz(54),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(790),
              top: layout.dy(146),
              width: layout.sz(108),
              height: layout.sz(108),
              child: GestureDetector(
                onTap: () => showSettingsSheet(context),
                child: Image.asset(
                  HealingAssets.profileOrb(HealingRootTab.sleep),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(77),
              top: layout.dy(416),
              right: layout.dx(77),
              height: layout.sz(220),
              child: GestureDetector(
                onTap: () => showSleepHistorySheet(context),
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: layout.dx(77),
              top: layout.dy(416),
              child: Text(
                '今晚好眠',
                style: HealingDesignSystem.eyebrow.copyWith(
                  fontSize: layout.sz(39),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(77),
              top: layout.dy(500),
              child: Text(
                '月光入梦',
                style: HealingDesignSystem.heroDisplay.copyWith(
                  fontSize: layout.sz(76),
                  letterSpacing: layout.sz(6),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(77),
              top: layout.dy(633),
              child: Text(
                '睡前冥想 · 20 分钟',
                style: HealingDesignSystem.subtitle.copyWith(
                  color: HealingDesignSystem.sleepMuted,
                  fontSize: layout.sz(32),
                  letterSpacing: layout.sz(1.2),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(76),
              top: layout.dy(726),
              width: layout.sz(136),
              height: layout.sz(136),
              child: GestureDetector(
                onTap: openSleepSession,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x66B0A4FF),
                        blurRadius: layout.sz(34),
                        spreadRadius: layout.sz(6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    HealingAssets.playButton(HealingRootTab.sleep),
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(32),
              top: layout.dy(1027),
              width: layout.sz(877),
              height: layout.sz(397),
              child: GlassDarkPanel(
                borderRadius: layout.sz(58),
                child: Padding(
                  padding: EdgeInsets.all(layout.sz(46)),
                  child: Row(
                    children: [
                      for (final item in [
                        ('睡眠故事', 'sleep_story_icon.png'),
                        ('呼吸', 'breath_icon.png'),
                        ('放松', 'relax_leaf_icon.png'),
                      ])
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: layout.sz(22),
                            ),
                            child: _FeatureTile(
                              label: item.$1,
                              iconPath:
                                  'assets/images/sleep/feature_art/${item.$2}',
                              layout: layout,
                              onTap: item.$2 == 'breath_icon.png'
                                  ? openBreath
                                  : () => openPlayer('pine_forest'),
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
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.label,
    required this.iconPath,
    required this.layout,
    this.onTap,
  });

  final String label;
  final String iconPath;
  final HealingLayout layout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          border: Border.all(color: const Color(0x1AFFFFFF)),
          borderRadius: BorderRadius.circular(layout.sz(44)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.sz(8),
            layout.sz(18),
            layout.sz(8),
            layout.sz(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: layout.sz(100),
                height: layout.sz(100),
                fit: BoxFit.contain,
              ),
              SizedBox(height: layout.sz(18)),
              Text(
                label,
                style: HealingDesignSystem.featureTileLabel.copyWith(
                  fontSize: layout.sz(34),
                ),
              ),
              SizedBox(height: layout.sz(18)),
              Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/images/sleep/status/card_indicator.png',
                  width: layout.sz(40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
