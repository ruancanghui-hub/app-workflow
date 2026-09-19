import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Result of [AppRatingPrompt.show].
enum AppRatingPromptResult {
  /// 好 → open store.
  positive,

  /// 差评 → open feedback.
  negative,

  /// 再用用看 → dismiss.
  later,
}

/// Friendly in-app rating dialog (图2-style).
abstract final class AppRatingPrompt {
  /// Returns the chosen action, or `null` if the barrier dismissed the dialog.
  static Future<AppRatingPromptResult?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String positiveLabel,
    required String negativeLabel,
    required String laterLabel,
  }) {
    return showFDialog<AppRatingPromptResult>(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          animation: animation,
          builder: (context, style) => _RatingBody(
            title: title,
            message: message,
            positiveLabel: positiveLabel,
            negativeLabel: negativeLabel,
            laterLabel: laterLabel,
          ),
        );
      },
    );
  }
}

class _RatingBody extends StatelessWidget {
  const _RatingBody({
    required this.title,
    required this.message,
    required this.positiveLabel,
    required this.negativeLabel,
    required this.laterLabel,
  });

  final String title;
  final String message;
  final String positiveLabel;
  final String negativeLabel;
  final String laterLabel;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colors.primary.withValues(alpha: 0.18),
                theme.colors.background,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              FLucideIcons.thumbsUp,
              size: 64,
              color: theme.colors.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            children: [
              Text(
                title,
                style: theme.typography.display.lg
                    .copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const FDivider(),
        _ActionRow(
          label: positiveLabel,
          color: theme.colors.primary,
          onPress: () =>
              Navigator.of(context).pop(AppRatingPromptResult.positive),
        ),
        const FDivider(),
        _ActionRow(
          label: negativeLabel,
          color: theme.colors.foreground,
          onPress: () =>
              Navigator.of(context).pop(AppRatingPromptResult.negative),
        ),
        const FDivider(),
        _ActionRow(
          label: laterLabel,
          color: theme.colors.mutedForeground,
          onPress: () => Navigator.of(context).pop(AppRatingPromptResult.later),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.color,
    required this.onPress,
  });

  final String label;
  final Color color;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return FTappable(
      onPress: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.typography.body.md.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
