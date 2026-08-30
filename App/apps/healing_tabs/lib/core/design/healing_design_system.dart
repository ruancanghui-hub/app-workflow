import 'dart:ui';

import 'package:flutter/material.dart';

import '../assets/healing_assets.dart';

/// Visual contract from `design-system-shared.json` + per-tab profiles.
abstract final class HealingDesignSystem {
  static const glassDarkFill = Color(0x8C161C24);
  static const glassDarkBorder = Color(0x24FFFFFF);
  static const glassLightFill = Color(0x9EFFFFFF);
  static const glassLightBorder = Color(0xB8FFFFFF);
  static final glassBlur = ImageFilter.blur(sigmaX: 24, sigmaY: 24);

  static const textLight = Color(0xFFFFFFFF);
  static const textLightMuted = Color(0xB3FFFFFF);
  static const textDark = Color(0xFF2C3338);
  static const textDarkMuted = Color(0x9E2C3338);
  static const sleepMuted = Color(0xFF9AA0B9);
  static const soundMuted = Color(0xFFA0AAB2);

  static Color navAccent(HealingRootTab tab) => switch (tab) {
        HealingRootTab.home => const Color(0xFFD4EFDF),
        HealingRootTab.sleep => const Color(0xFFB0A4FF),
        HealingRootTab.meditation => const Color(0xFFE6A23C),
        HealingRootTab.sound => const Color(0xFFB2F2BB),
      };

  static const pageTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: 0.72,
    color: textLight,
  );

  static const pageTitleDark = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: 0.72,
    color: textDark,
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.6,
    color: textLightMuted,
  );

  static const sectionTitleLight = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textLight,
  );

  static const sectionTitleDark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textDark,
  );

  static const cardLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
    color: textLight,
  );

  static const navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.48,
  );

  static const eyebrow = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textLightMuted,
  );

  static const heroDisplay = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w500,
    height: 1.12,
    letterSpacing: 3.52,
    color: textLight,
  );

  static const quoteMain = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.96,
    color: textDark,
  );

  static const quoteSub = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textDarkMuted,
  );

  static const gridLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textDark,
  );

  static const heroCardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textLight,
  );

  static const listTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textLight,
  );

  static const listSub = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: soundMuted,
  );

  static const featureTileLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: textLight,
  );

  static const tagLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: textLightMuted,
  );
}
