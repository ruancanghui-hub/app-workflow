import 'package:get/get.dart';

import '../env/app_environment.dart';
import 'remote_config.dart';

/// Whether the **诊断入口** may be opened.
class DiagnosticsAccess {
  DiagnosticsAccess({
    required this.environment,
    required this.remoteConfig,
  });

  final AppEnvironment environment;
  final RemoteConfig remoteConfig;

  /// Feature flag: when true, settings may show an explicit entry (prod).
  bool get flagEnabled => remoteConfig.isFeatureEnabled(
        'diagnostics_entry_enabled',
        defaultValue: false,
      );

  /// Dev always; prod via flag (settings) or secret gesture (caller).
  bool get canShowSettingsEntry => environment.isDev || flagEnabled;

  bool get isDev => environment.isDev;
}

/// Secret gesture: N taps within a short window.
class SecretTapDetector {
  SecretTapDetector({
    this.requiredTaps = 7,
    this.window = const Duration(seconds: 3),
  });

  final int requiredTaps;
  final Duration window;

  final _times = <DateTime>[];

  /// Returns true when the threshold is reached (and resets).
  bool registerTap() {
    final now = DateTime.now();
    _times.removeWhere((t) => now.difference(t) > window);
    _times.add(now);
    if (_times.length >= requiredTaps) {
      _times.clear();
      return true;
    }
    return false;
  }

  void reset() => _times.clear();
}

DiagnosticsAccess get diagnosticsAccess => Get.find<DiagnosticsAccess>();
