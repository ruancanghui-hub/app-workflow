import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../root_shell/widgets/healing_tab_bar.dart';

class SoundTabPage extends StatelessWidget {
  const SoundTabPage({
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
          HealingAssets.background(HealingRootTab.sound),
          fit: BoxFit.cover,
        ),
        const Positioned(
          left: 48,
          top: 120,
          child: Text(
            '声音',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        _HeaderIcon(left: 668, top: 106, asset: HealingAssets.searchButton(HealingRootTab.sound)),
        _HeaderIcon(left: 736, top: 106, asset: HealingAssets.addButton(HealingRootTab.sound)),
        Positioned(
          left: 808,
          top: 104,
          width: 62,
          height: 62,
          child: Image.asset(HealingAssets.profileOrb(HealingRootTab.sound)),
        ),
        Positioned(
          left: 40,
          top: 164,
          width: 861,
          height: 360,
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
              ),
            ),
          ),
        ),
        const Positioned(
          left: 64,
          top: 196,
          child: Text(
            '白噪音时刻',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 64,
          top: 442,
          width: 672,
          height: 40,
          child: _Waveform(),
        ),
        Positioned(
          left: 780,
          top: 434,
          width: 86,
          height: 86,
          child: Image.asset(HealingAssets.playButton(HealingRootTab.sound)),
        ),
        Positioned(
          left: 40,
          top: 548,
          width: 861,
          height: 164,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x85161C24),
                  border: Border.all(color: const Color(0x24FFFFFF)),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 58,
          top: 566,
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              HealingAssets.background(HealingRootTab.sound),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Positioned(
          left: 204,
          top: 586,
          child: Text(
            '山谷雨声',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const Positioned(
          left: 204,
          top: 618,
          child: Text(
            '专注 · 45 分钟',
            style: TextStyle(fontSize: 14, color: Color(0xFFA0AAB2)),
          ),
        ),
        Positioned(
          left: 204,
          top: 650,
          child: Row(
            children: [
              for (final tag in ['自然', '雨声', '风声'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      border: Border.all(color: const Color(0x24FFFFFF)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 12, color: Color(0xB3FFFFFF)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        HealingTabBar(
          screenTab: HealingRootTab.sound,
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

class _Waveform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 15; i++)
          Container(
            width: 4,
            height: [16.0, 22.0, 35.0, 28.0, 18.0][i % 5],
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xC7FFFFFF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
