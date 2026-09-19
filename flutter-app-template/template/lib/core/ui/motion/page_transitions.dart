import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

export 'package:animations/animations.dart'
    show
        FadeThroughTransition,
        PageTransitionSwitcher,
        SharedAxisTransitionType;

/// Shared-axis page transition for GetX.
class SharedAxisGetPage<T> extends GetPage<T> {
  SharedAxisGetPage({
    required super.name,
    required super.page,
    super.binding,
    super.bindings,
    super.middlewares,
    this.axis = SharedAxisTransitionType.horizontal,
  }) : super(
          customTransition: _SharedAxisTransition(axis),
          transitionDuration: const Duration(milliseconds: 300),
        );

  final SharedAxisTransitionType axis;
}

/// Fade-through page transition for GetX.
class FadeThroughGetPage<T> extends GetPage<T> {
  FadeThroughGetPage({
    required super.name,
    required super.page,
    super.binding,
    super.bindings,
    super.middlewares,
  }) : super(
          customTransition: _FadeThroughTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Fade-scale page transition for GetX.
class FadeScaleGetPage<T> extends GetPage<T> {
  FadeScaleGetPage({
    required super.name,
    required super.page,
    super.binding,
    super.bindings,
    super.middlewares,
  }) : super(
          customTransition: _FadeScaleTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class _SharedAxisTransition extends CustomTransition {
  _SharedAxisTransition(this.axis);

  final SharedAxisTransitionType axis;

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: axis,
      child: child,
    );
  }
}

class _FadeThroughTransition extends CustomTransition {
  _FadeThroughTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _FadeScaleTransition extends CustomTransition {
  _FadeScaleTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeScaleTransition(
      animation: animation,
      child: child,
    );
  }
}
