import 'package:flutter/material.dart';

import '../assets/healing_assets.dart';
import 'healing_canvas.dart';

/// Maps the 941×1672 design canvas to the phone viewport by width.
class HealingLayout {
  const HealingLayout(this.size);

  final Size size;

  factory HealingLayout.of(BuildContext context) =>
      HealingLayout(MediaQuery.sizeOf(context));

  double get width => size.width;
  double get height => size.height;

  /// Uniform scale based on design width so narrow iPhones do not crop the artboard.
  double get scale => width / HealingCanvas.designWidth;

  double get _offsetX => 0;

  double dx(double designX) => _offsetX + designX * scale;

  double dy(double designY) => designY * scale;

  double sz(double designPx) => designPx * scale;

  /// `docs/字号排板.md` is authored on a 375pt phone. Convert those pt values
  /// into scaled pixels that stay consistent across devices.
  static const referenceWidthPt = 375.0;

  double pt(double value375) =>
      sz(value375 * HealingCanvas.designWidth / referenceWidthPt);

  // —— 字号排板.md type scale ——
  double get fontPageTitle => pt(24);
  double get fontModuleTitle => pt(18);
  double get fontSecondaryTitle => pt(16);
  double get fontCardTitle => pt(14);
  double get fontAssist => pt(12);
  double get fontIntro => pt(13);
  double get fontButton => pt(14);

  // —— spacing ——
  double get pagePad => pt(16);
  double get moduleSpace => pt(28);
  double get sectionTitleGap => pt(12);
  double get cardGap => pt(12);
  double get chipGap => pt(10);

  // —— radii ——
  double get radiusContent => pt(16);
  double get radiusDepart => pt(14);
  double get radiusCapsule => pt(20);
  double get radiusChip => pt(10);
  double get radiusMember => pt(18);

  EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: pagePad);

  double responsiveFontSize(double designSize) => sz(designSize);

  /// Design bottom inset for the floating tab bar (20px on the artboard).
  double tabBarBottomInset(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final designBottom = dy(20);
    return safeBottom > designBottom ? safeBottom : designBottom;
  }

  /// Unified docked tab bar height (max across all tab artboards).
  static const dockedTabBarDesignHeight = 194.0;

  double get tabBarDockedHeight => sz(dockedTabBarDesignHeight);

  double tabBarDockedTop(BuildContext context) =>
      height - tabBarBottomInset(context) - tabBarDockedHeight;

  /// Tab 栏上方「正在播放」迷你条高度（375 基准 pt）。
  static const miniPlayerHeightPt = 64.0;
  static const miniPlayerGapPt = 8.0;

  double get miniPlayerHeight => pt(miniPlayerHeightPt);
  double get miniPlayerGap => pt(miniPlayerGapPt);

  /// 迷你条可见时，内容区额外底垫。
  double miniPlayerClearance({required bool visible}) =>
      visible ? miniPlayerHeight + miniPlayerGap : 0;

  double nowPlayingBarTop(BuildContext context) =>
      tabBarDockedTop(context) - miniPlayerGap - miniPlayerHeight;

  double tabBarHeight(HealingRootTab tab) => switch (tab) {
    HealingRootTab.meditation => sz(158),
    HealingRootTab.sleep => sz(194),
    HealingRootTab.home || HealingRootTab.device => sz(192),
  };

  double tabBarTop(BuildContext context, HealingRootTab tab) =>
      height - tabBarBottomInset(context) - tabBarHeight(tab);

  /// Gap between action cards and tab bar on the home artboard.
  static const cardToTabGap = 90.0;

  /// Gap between section title row and cards on the home artboard.
  static const sectionToCardGap = 96.0;
}
