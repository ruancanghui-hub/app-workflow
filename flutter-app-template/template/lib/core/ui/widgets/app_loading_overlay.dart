import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'app_loading.dart';

/// Blocking full-screen loading dialog (HTTP / long tasks).
abstract final class AppLoadingOverlay {
  static bool _visible = false;

  static bool get isVisible => _visible;

  /// Shows a non-dismissible loading dialog. Call [hide] when done.
  static Future<void> show(
    BuildContext context, {
    String? message,
  }) async {
    if (_visible) return;
    _visible = true;
    try {
      await showFDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context, style, animation) {
          return FDialog(
            animation: animation,
            builder: (context, style) => Padding(
              padding: const EdgeInsets.all(32),
              child: AppLoading(label: message),
            ),
          );
        },
      );
    } finally {
      _visible = false;
    }
  }

  /// Pops the loading dialog if shown.
  static void hide(BuildContext context) {
    if (!_visible) return;
    final navigator = Navigator.of(context, rootNavigator: false);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _visible = false;
  }

  /// Runs [action] while the overlay is visible.
  static Future<T> during<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? message,
  }) async {
    // Fire-and-forget show; wait a frame so the dialog mounts.
    // ignore: unawaited_futures
    show(context, message: message);
    await Future<void>.delayed(Duration.zero);
    try {
      return await action();
    } finally {
      if (context.mounted) hide(context);
    }
  }
}
