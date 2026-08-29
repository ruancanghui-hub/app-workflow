abstract final class HealingCanvas {
  static const designWidth = 941.0;
  static const designHeight = 1672.0;

  static double scaleForWidth(double width) => width / designWidth;

  static double scaled(double designPx, double width) =>
      designPx * scaleForWidth(width);
}
