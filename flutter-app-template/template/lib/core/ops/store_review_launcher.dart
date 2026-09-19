import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/widgets/app_toast.dart';
import 'store_review_config.dart';

/// Opens the configured app-store listing for 好评.
abstract final class StoreReviewLauncher {
  static Future<bool> openStore(
    BuildContext context, {
    StoreReviewConfig? config,
    String? missingUrlMessage,
  }) async {
    final cfg = config ?? StoreReviewConfig.fromEnvironment();
    final url = _urlForPlatform(cfg);
    if (url == null || url.isEmpty) {
      if (context.mounted && missingUrlMessage != null) {
        AppToast.info(context, missingUrlMessage);
      }
      return false;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String? _urlForPlatform(StoreReviewConfig config) {
    if (kIsWeb) return null;
    if (Platform.isIOS) return config.iosStoreUrl.trim();
    if (Platform.isAndroid) return config.androidStoreUrl.trim();
    return null;
  }
}
