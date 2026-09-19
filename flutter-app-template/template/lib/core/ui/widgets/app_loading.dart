import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Loading indicator wrappers around [FCircularProgress].
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label}) : inline = false;

  const AppLoading.inline({super.key, this.label}) : inline = true;

  final String? label;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FCircularProgress(),
        if (label != null) ...[
          const SizedBox(width: 12),
          Flexible(child: Text(label!, style: theme.typography.body.sm)),
        ],
      ],
    );

    if (inline) return content;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FCircularProgress(),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: theme.typography.body.sm),
          ],
        ],
      ),
    );
  }
}
