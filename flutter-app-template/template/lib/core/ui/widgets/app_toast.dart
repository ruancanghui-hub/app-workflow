import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Toast helpers over [showFToast] (requires [FToaster] ancestor).
abstract final class AppToast {
  static void info(BuildContext context, String title, {String? description}) {
    showFToast(
      context: context,
      variant: FToastVariant.primary,
      title: Text(title),
      description: description == null ? null : Text(description),
      icon: const Icon(FLucideIcons.info),
    );
  }

  static void success(BuildContext context, String title, {String? description}) {
    showFToast(
      context: context,
      variant: FToastVariant.primary,
      title: Text(title),
      description: description == null ? null : Text(description),
      icon: const Icon(FLucideIcons.circleCheck),
    );
  }

  static void error(BuildContext context, String title, {String? description}) {
    showFToast(
      context: context,
      variant: FToastVariant.destructive,
      title: Text(title),
      description: description == null ? null : Text(description),
      icon: const Icon(FLucideIcons.circleAlert),
    );
  }
}
