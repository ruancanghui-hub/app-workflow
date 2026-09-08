import 'package:flutter/material.dart';

/// Decodes local raster assets at their rendered size so they remain in
/// Flutter's image cache without retaining full-resolution bitmaps.
class CachedCoverImage extends StatelessWidget {
  const CachedCoverImage({
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.errorBuilder,
    super.key,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final logicalWidth =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final logicalHeight =
            height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : null);
        final cacheWidth = logicalWidth == null
            ? null
            : (logicalWidth * pixelRatio).round();
        final cacheHeight = logicalHeight == null
            ? null
            : (logicalHeight * pixelRatio).round();
        final ImageProvider<Object> provider =
            cacheWidth == null && cacheHeight == null
            ? AssetImage(asset)
            : ResizeImage(
                AssetImage(asset),
                width: cacheWidth,
                height: cacheHeight,
              );
        return Image(
          image: provider,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
