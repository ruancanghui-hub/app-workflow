import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Section title used above lists / groups.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.title, {super.key, this.padding});

  final String title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
