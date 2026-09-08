import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../storage/key_value_store.dart';

/// Requests Apple's standard, neutral App Store rating prompt at most once per
/// 180 days. StoreKit decides whether the prompt is actually shown.
class AppStoreReviewRequester {
  AppStoreReviewRequester(this._store);

  static const _lastRequestKey = 'app_store_review_last_request_at';
  static const _minimumUse = Duration(seconds: 30);
  static const _minimumInterval = Duration(days: 180);
  static const _channel = MethodChannel('com.yunyao.healing_tabs/app_review');

  final KeyValueStore _store;

  Future<void> scheduleForCurrentSession() async {
    if (!Platform.isIOS || !await _canRequestAgain()) return;

    await Future<void>.delayed(_minimumUse);
    if (!Platform.isIOS || !await _canRequestAgain()) return;

    await _store.setString(
      _lastRequestKey,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
    try {
      await _channel.invokeMethod<void>('requestReview');
    } on PlatformException {
      // A review request must never affect the app experience.
    }
  }

  Future<bool> _canRequestAgain() async {
    final raw = await _store.getString(_lastRequestKey);
    final timestamp = int.tryParse(raw ?? '');
    if (timestamp == null) return true;
    final lastRequest = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(lastRequest) >= _minimumInterval;
  }
}
