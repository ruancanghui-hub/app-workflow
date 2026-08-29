import 'package:flutter/material.dart';

import '../../../core/design/healing_canvas.dart';

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = HealingCanvas.scaleForWidth(constraints.maxWidth);
        return SizedBox(
          width: constraints.maxWidth,
          height: HealingCanvas.designHeight * scale,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: HealingCanvas.designWidth,
              maxWidth: HealingCanvas.designWidth,
              minHeight: HealingCanvas.designHeight,
              maxHeight: HealingCanvas.designHeight,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: HealingCanvas.designWidth,
                  height: HealingCanvas.designHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
