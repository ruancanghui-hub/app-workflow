import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/compliance/legal_copy.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({required this.kind, super.key});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final title = kind == LegalDocumentKind.privacy
        ? LegalCopy.privacyTitle
        : LegalCopy.termsTitle;
    final body = kind == LegalDocumentKind.privacy
        ? LegalCopy.privacyBody
        : LegalCopy.termsBody;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0.5,
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Text(
            body,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ),
      ),
    );
  }
}
