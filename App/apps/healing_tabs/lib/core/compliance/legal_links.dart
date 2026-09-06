import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes/app_routes.dart';
import 'legal_copy.dart';

/// 优先打开公网法律页；失败则回退到应用内正文页。
Future<void> openLegalDocument(LegalDocumentKind kind) async {
  final url = Uri.parse(
    kind == LegalDocumentKind.privacy
        ? LegalCopy.privacyUrl
        : LegalCopy.termsUrl,
  );
  try {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (ok) return;
  } catch (e, st) {
    debugPrint('[LegalLink] launch failed: $e\n$st');
  }
  final route = kind == LegalDocumentKind.privacy
      ? AppRoutes.privacyPolicy
      : AppRoutes.userTerms;
  await Get.toNamed(route);
}
