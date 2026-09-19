import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.radiusMd,
    required this.colorAccent,
  });

  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double radiusMd;
  final Color colorAccent;

  static const light = AppTokens(
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    radiusMd: 12,
    colorAccent: Color(0xFF1B6CA8),
  );

  @override
  AppTokens copyWith({
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? radiusMd,
    Color? colorAccent,
  }) {
    return AppTokens(
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      radiusMd: radiusMd ?? this.radiusMd,
      colorAccent: colorAccent ?? this.colorAccent,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      colorAccent: Color.lerp(colorAccent, other.colorAccent, t)!,
    );
  }
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

extension AppTokensX on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}
