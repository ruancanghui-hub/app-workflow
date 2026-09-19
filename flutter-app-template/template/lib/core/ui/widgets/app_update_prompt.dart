import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'app_button.dart';

/// Version-update prompt as a bottom sheet (`showFSheet`).
abstract final class AppUpdatePrompt {
  /// Returns `true` if Update is chosen, `false` if Later, `null` if dismissed.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? version,
    String? notes,
    String updateLabel = 'Update',
    String laterLabel = 'Later',
  }) {
    return showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      useSafeArea: true,
      builder: (context) {
        final theme = FTheme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.mutedForeground.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const SizedBox(width: 36, height: 4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.typography.display.lg
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              if (version != null) ...[
                const SizedBox(height: 8),
                Text(
                  version,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              if (notes != null) ...[
                const SizedBox(height: 12),
                Text(notes, style: theme.typography.body.sm),
              ],
              const SizedBox(height: 24),
              AppButton(
                onPress: () => Navigator.of(context).pop(true),
                child: Text(updateLabel),
              ),
              const SizedBox(height: 8),
              AppButton(
                variant: AppButtonVariant.outline,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(laterLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}
