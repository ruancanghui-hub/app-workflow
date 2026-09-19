import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Thin Forui [FButton] wrapper with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPress,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.mainAxisSize = MainAxisSize.max,
    super.key,
  });

  final VoidCallback? onPress;
  final Widget child;
  final AppButtonVariant variant;
  final bool loading;
  final MainAxisSize mainAxisSize;

  FButtonVariant get _fVariant => switch (variant) {
        AppButtonVariant.primary => FButtonVariant.primary,
        AppButtonVariant.secondary => FButtonVariant.secondary,
        AppButtonVariant.destructive => FButtonVariant.destructive,
        AppButtonVariant.outline => FButtonVariant.outline,
        AppButtonVariant.ghost => FButtonVariant.ghost,
      };

  @override
  Widget build(BuildContext context) {
    final effectivePress = loading ? null : onPress;
    return FButton(
      variant: _fVariant,
      onPress: effectivePress,
      mainAxisSize: mainAxisSize,
      prefix: loading ? const FCircularProgress() : null,
      child: child,
    );
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  outline,
  ghost,
}
