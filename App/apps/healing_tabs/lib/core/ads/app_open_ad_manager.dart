import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_ids.dart';

/// 开屏广告加载与展示（冷启动 + 回前台）。
class AppOpenAdManager extends GetxService {
  static const maxCacheDuration = Duration(hours: 4);

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadTime;
  var _isShowingAd = false;
  var _isLoading = false;

  /// 冷启动刚展示过后，短暂忽略回前台，避免连弹。
  DateTime? _suppressUntil;

  bool get isAdAvailable => _appOpenAd != null;

  bool get isShowingAd => _isShowingAd;

  Future<void> loadAd() async {
    if (kIsWeb) return;
    if (_isLoading || isAdAvailable) return;
    _isLoading = true;
    final completer = Completer<void>();
    try {
      await AppOpenAd.load(
        adUnitId: AdMobIds.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _appOpenLoadTime = DateTime.now();
            _isLoading = false;
            debugPrint('[AppOpenAd] loaded');
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            _appOpenAd = null;
            _appOpenLoadTime = null;
            _isLoading = false;
            debugPrint('[AppOpenAd] failed to load: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _isLoading = false;
        },
      );
    } catch (e, st) {
      _isLoading = false;
      debugPrint('[AppOpenAd] load error: $e\n$st');
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// 若有可用广告则展示。返回是否真正开始展示。
  Future<bool> showAdIfAvailable({VoidCallback? onComplete}) async {
    if (kIsWeb) {
      onComplete?.call();
      return false;
    }
    final suppressUntil = _suppressUntil;
    if (suppressUntil != null && DateTime.now().isBefore(suppressUntil)) {
      onComplete?.call();
      return false;
    }
    if (_isShowingAd) {
      return false;
    }
    if (!isAdAvailable) {
      unawaited(loadAd());
      onComplete?.call();
      return false;
    }
    final loadTime = _appOpenLoadTime;
    if (loadTime == null ||
        DateTime.now().difference(loadTime) > maxCacheDuration) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      unawaited(loadAd());
      onComplete?.call();
      return false;
    }

    final ad = _appOpenAd!;
    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('[AppOpenAd] showed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AppOpenAd] failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        unawaited(loadAd());
        if (!done.isCompleted) done.complete();
        onComplete?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AppOpenAd] dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _suppressUntil = DateTime.now().add(const Duration(seconds: 5));
        unawaited(loadAd());
        if (!done.isCompleted) done.complete();
        onComplete?.call();
      },
    );

    try {
      await ad.show();
      await done.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {},
      );
      return true;
    } catch (e, st) {
      debugPrint('[AppOpenAd] show error: $e\n$st');
      _isShowingAd = false;
      _appOpenAd = null;
      onComplete?.call();
      return false;
    }
  }
}

/// 监听应用回前台并尝试展示开屏广告。
class AppOpenAdLifecycleReactor {
  AppOpenAdLifecycleReactor(this._manager);

  final AppOpenAdManager _manager;
  StreamSubscription<AppState>? _sub;

  void start() {
    AppStateEventNotifier.startListening();
    _sub?.cancel();
    _sub = AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.foreground) {
        unawaited(_manager.showAdIfAvailable());
      }
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
