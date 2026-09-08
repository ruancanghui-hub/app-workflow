import 'package:flutter/material.dart';

/// Decodes local cover art at its rendered size so it remains in Flutter's
/// image cache when a content category is rebuilt.
class CachedCoverImage extends StatelessWidget {
  const CachedCoverImage({
    required this.asset,
    required this.width,
    required this.height,
    super.key,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Image(
      image: ResizeImage(
        AssetImage(asset),
        width: (width * pixelRatio).round(),
        height: (height * pixelRatio).round(),
      ),
      width: width,
      height: height,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}
