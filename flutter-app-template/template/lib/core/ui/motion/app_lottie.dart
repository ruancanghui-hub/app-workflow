import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lottie/lottie.dart';

/// Lottie asset helper with unified error placeholder.
class AppLottie extends StatelessWidget {
  const AppLottie.asset(
    this.asset, {
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.placeholder,
    super.key,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) =>
          placeholder ??
          SizedBox(
            width: width ?? 64,
            height: height ?? 64,
            child: Icon(
              FLucideIcons.imageOff,
              color: theme.colors.mutedForeground,
            ),
          ),
    );
  }
}
