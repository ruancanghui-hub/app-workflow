import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/injection/app_bindings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/ads/ads_bootstrap.dart';
import '../../../core/ads/app_open_ad_manager.dart';
import '../../../core/compliance/privacy_consent.dart';
import '../../../core/storage/key_value_store.dart';

/// 首次启动隐私同意门：同意前不初始化广告 SDK。
class PrivacyConsentPage extends StatefulWidget {
  const PrivacyConsentPage({super.key});

  @override
  State<PrivacyConsentPage> createState() => _PrivacyConsentPageState();
}

class _PrivacyConsentPageState extends State<PrivacyConsentPage> {
  var _agreed = false;
  var _busy = false;

  Future<void> _continue() async {
    if (!_agreed || _busy) return;
    setState(() => _busy = true);
    try {
      final store = Get.find<KeyValueStore>();
      await PrivacyConsent.setConsented(store, value: true);
      await AppBindings.wireFirebaseAdapters();
      await AdsBootstrap.ensureReady();
      if (!mounted) return;
      if (Get.isRegistered<AppOpenAdManager>()) {
        AppOpenAdLifecycleReactor(Get.find<AppOpenAdManager>()).start();
      }
      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      debugPrint('[PrivacyConsent] continue failed: $e\n$st');
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('初始化失败，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1424),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '欢迎使用云遥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '在开始前，请阅读并同意我们的隐私政策与用户协议。'
                '同意后，我们才会初始化广告与分析相关服务。',
                style: TextStyle(color: Color(0xCCFFFFFF), height: 1.45),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      '摘要：\n'
                      '• 本机身份、睡眠会话、收藏与设置默认保存在本机\n'
                      '• 戒指体征仅在您配对并使用相关功能时读取\n'
                      '• 同意后可能使用 Firebase 诊断/分析与 AdMob 开屏广告\n'
                      '• 本应用为 wellness 工具，不提供医疗诊断\n'
                      '• 您可随时在「我的」中删除本机数据',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: const Color(0xFF6B8CF5),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _agreed = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: '我已阅读并同意'),
                            TextSpan(
                              text: '《隐私政策》',
                              style: const TextStyle(
                                color: Color(0xFF9BB4FF),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Get.toNamed(AppRoutes.privacyPolicy),
                            ),
                            const TextSpan(text: '与'),
                            TextSpan(
                              text: '《用户协议》',
                              style: const TextStyle(
                                color: Color(0xFF9BB4FF),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => Get.toNamed(AppRoutes.userTerms),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _agreed && !_busy ? _continue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F28),
                    disabledBackgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: Text(_busy ? '请稍候…' : '同意并继续'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
