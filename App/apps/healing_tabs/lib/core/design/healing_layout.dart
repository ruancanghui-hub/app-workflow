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

  EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: dx(48));

  double responsiveFontSize(double designSize) => sz(designSize);

  /// Design bottom inset for the floating tab bar (20px on the artboard).
  double tabBarBottomInset(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final designBottom = dy(20);
    return safeBottom > designBottom ? safeBottom : designBottom;
  }

  double tabBarHeight(HealingRootTab tab) => switch (tab) {
    HealingRootTab.meditation => sz(158),
    HealingRootTab.sleep => sz(194),
    HealingRootTab.home || HealingRootTab.sound => sz(192),
  };

  double tabBarTop(BuildContext context, HealingRootTab tab) =>
      height - tabBarBottomInset(context) - tabBarHeight(tab);

  /// Gap between action cards and tab bar on the home artboard.
  static const cardToTabGap = 90.0;

  /// Gap between section title row and cards on the home artboard.
  static const sectionToCardGap = 96.0;
}
