import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/ui/ui.dart';

/// Tiny page used only to demonstrate route transitions.
class CatalogTransitionPage extends StatelessWidget {
  const CatalogTransitionPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return FScaffold(
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This page exists to preview the navigation transition.\nTap back to return.',
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
