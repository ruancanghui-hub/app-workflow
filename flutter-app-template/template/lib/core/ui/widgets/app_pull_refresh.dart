import 'package:flutter/cupertino.dart';

import 'package:forui/forui.dart';

/// Pull-to-refresh over a [CustomScrollView], with a Forui spinner.
class AppPullRefresh extends StatelessWidget {
  const AppPullRefresh({
    required this.onRefresh,
    required this.slivers,
    this.physics,
    super.key,
  });

  final RefreshCallback onRefresh;
  final List<Widget> slivers;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder: _indicator,
        ),
        ...slivers,
      ],
    );
  }

  static Widget _indicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final visible = refreshState != RefreshIndicatorMode.inactive ||
        pulledExtent > 8;
    if (!visible) return const SizedBox.shrink();

    final progress = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Opacity(
          opacity: progress,
          child: const FCircularProgress.loader(),
        ),
      ),
    );
  }
}
