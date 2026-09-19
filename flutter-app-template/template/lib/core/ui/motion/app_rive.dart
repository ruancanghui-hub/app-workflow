import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:rive/rive.dart';

/// Rive asset helper with loading / error placeholders.
class AppRive extends StatefulWidget {
  const AppRive.asset(
    this.asset, {
    this.width,
    this.height,
    this.placeholder,
    this.errorPlaceholder,
    super.key,
  });

  final String asset;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorPlaceholder;

  @override
  State<AppRive> createState() => _AppRiveState();
}

class _AppRiveState extends State<AppRive> {
  late final FileLoader _loader = FileLoader.fromAsset(
    widget.asset,
    riveFactory: Factory.rive,
  );

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final fallback = SizedBox(
      width: widget.width ?? 64,
      height: widget.height ?? 64,
      child: Icon(
        FLucideIcons.imageOff,
        color: theme.colors.mutedForeground,
      ),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RiveWidgetBuilder(
        fileLoader: _loader,
        builder: (context, state) => switch (state) {
          RiveLoading() =>
            widget.placeholder ?? const Center(child: FCircularProgress()),
          RiveFailed() => widget.errorPlaceholder ?? fallback,
          RiveLoaded(:final controller) => RiveWidget(controller: controller),
        },
      ),
    );
  }
}
