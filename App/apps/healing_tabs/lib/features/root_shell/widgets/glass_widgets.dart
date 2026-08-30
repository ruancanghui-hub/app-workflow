import 'package:flutter/material.dart';

import '../../../core/design/healing_design_system.dart';

class GlassDarkPanel extends StatelessWidget {
  const GlassDarkPanel({
    required this.child,
    this.borderRadius = 22,
    super.key,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: HealingDesignSystem.glassBlur,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: HealingDesignSystem.glassDarkFill,
            border: Border.all(color: HealingDesignSystem.glassDarkBorder),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassLightPanel extends StatelessWidget {
  const GlassLightPanel({
    required this.child,
    this.borderRadius = 22,
    super.key,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: HealingDesignSystem.glassBlur,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: HealingDesignSystem.glassLightFill,
            border: Border.all(color: HealingDesignSystem.glassLightBorder),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    required this.asset,
    this.size = 56,
    this.iconSize = 28,
    this.light = false,
    super.key,
  });

  final String asset;
  final double size;
  final double iconSize;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: HealingDesignSystem.glassBlur,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: light
                ? HealingDesignSystem.glassLightFill
                : HealingDesignSystem.glassDarkFill,
            shape: BoxShape.circle,
            border: Border.all(
              color: light
                  ? HealingDesignSystem.glassLightBorder
                  : HealingDesignSystem.glassDarkBorder,
            ),
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Image.asset(
                asset,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow({
    required this.title,
    required this.decoAsset,
    required this.titleStyle,
    this.decoHeight = 18,
    super.key,
  });

  final String title;
  final String decoAsset;
  final TextStyle titleStyle;
  final double decoHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(width: 6),
        Image.asset(decoAsset, height: decoHeight, fit: BoxFit.contain),
      ],
    );
  }
}
