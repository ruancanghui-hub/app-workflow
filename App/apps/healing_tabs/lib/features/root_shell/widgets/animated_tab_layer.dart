import 'package:flutter/material.dart';

/// Tab 切换时的页面交叉淡入淡出与轻微横向位移。
class AnimatedTabLayer extends StatelessWidget {
  const AnimatedTabLayer({
    required this.visible,
    required this.tabIndex,
    required this.activeIndex,
    required this.child,
    super.key,
  });

  final bool visible;
  final int tabIndex;
  final int activeIndex;
  final Widget child;

  static const duration = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;
  static const _slideOffset = 0.04;

  Offset get _targetOffset {
    if (visible) return Offset.zero;
    return tabIndex < activeIndex
        ? const Offset(-_slideOffset, 0)
        : const Offset(_slideOffset, 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: curve,
        child: AnimatedSlide(
          offset: _targetOffset,
          duration: duration,
          curve: curve,
          child: child,
        ),
      ),
    );
  }
}
