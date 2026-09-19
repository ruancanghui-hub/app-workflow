import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'app_button.dart';

/// Confirm / alert dialogs via [showFDialog].
abstract final class AppDialog {
  /// Returns `true` if confirmed, `false` if cancelled, `null` if dismissed.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return showFDialog<bool>(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          animation: animation,
          builder: (context, style) => _DialogBody(
            title: title,
            message: message,
            actions: [
              AppButton(
                variant: AppButtonVariant.outline,
                mainAxisSize: MainAxisSize.min,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
              AppButton(
                variant: destructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.primary,
                mainAxisSize: MainAxisSize.min,
                onPress: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Alert with a single dismiss action. Returns after close.
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    String? message,
    String okLabel = 'OK',
  }) {
    return showFDialog<void>(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          animation: animation,
          builder: (context, style) => _DialogBody(
            title: title,
            message: message,
            actions: [
              AppButton(
                mainAxisSize: MainAxisSize.min,
                onPress: () => Navigator.of(context).pop(),
                child: Text(okLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({
    required this.title,
    required this.actions,
    this.message,
  });

  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.typography.display.lg
                .copyWith(fontWeight: FontWeight.w700),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: theme.typography.body.sm
                  .copyWith(color: theme.colors.mutedForeground),
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
