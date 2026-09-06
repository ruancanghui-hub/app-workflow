import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_open_ad_manager.dart';

/// 在用户同意隐私政策后再初始化 Mobile Ads / UMP / ATT，并预加载开屏。
///
/// UMP 在后台跑、不阻塞进首页（国内常连不上 fundingchoices，原生约 10s 超时）。
abstract final class AdsBootstrap {
  static var _ready = false;
  static var _starting = false;

  static bool get isReady => _ready;

  static Future<void> ensureReady() async {
    if (kIsWeb || _ready) return;
    if (_starting) {
      while (_starting && !_ready) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _starting = true;
    try {
      await MobileAds.instance.initialize();
      // 不 await：失败/超时也不挡进首页与开屏预加载。
      unawaited(_gatherConsent());
      await _requestTrackingIfNeeded();
      if (!Get.isRegistered<AppOpenAdManager>()) {
        Get.put(AppOpenAdManager(), permanent: true);
      }
      unawaited(Get.find<AppOpenAdManager>().loadAd());
      _ready = true;
    } finally {
      _starting = false;
    }
  }

  static Future<void> _gatherConsent() async {
    try {
      final params = ConsentRequestParameters();
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!completer.isCompleted) completer.complete();
        },
        (error) {
          debugPrint('[AdsBootstrap] consent update failed: $error');
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[AdsBootstrap] consent update timed out (non-blocking)');
        },
      );
    } catch (e, st) {
      debugPrint('[AdsBootstrap] consent error: $e\n$st');
    }
  }

  static Future<void> _requestTrackingIfNeeded() async {
    if (kIsWeb) return;
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      final status = await Permission.appTrackingTransparency.status;
      if (status.isDenied) {
        await Permission.appTrackingTransparency.request();
      }
    } catch (e, st) {
      debugPrint('[AdsBootstrap] ATT error: $e\n$st');
    }
  }
}
