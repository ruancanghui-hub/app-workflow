import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton placeholder using [shimmer].
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    required this.child,
    this.enabled = true,
    super.key,
  });

  /// List-style skeleton lines.
  factory AppSkeleton.list({
    int lines = 3,
    bool enabled = true,
    Key? key,
  }) {
    return AppSkeleton(
      key: key,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Container(
              height: 14,
              width: i == lines - 1 ? 160 : double.infinity,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  /// Card-shaped skeleton (image + text lines).
  factory AppSkeleton.card({
    bool enabled = true,
    Key? key,
  }) {
    return AppSkeleton(
      key: key,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 14, width: double.infinity, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 14, width: 180, color: Colors.white),
        ],
      ),
    );
  }

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: enabled,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}
