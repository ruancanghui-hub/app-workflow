import 'package:flutter/scheduler.dart';

import 'app_events.dart';
import 'remote_config.dart';

/// **帧卡顿监测** — FrameTiming based, reports via [AppEvents].
class JankMonitor {
  JankMonitor({
    required this.appEvents,
    required this.remoteConfig,
    this.threshold = const Duration(milliseconds: 33),
    this.maxRecent = 50,
  });

  final AppEvents appEvents;
  final RemoteConfig remoteConfig;
  final Duration threshold;
  final int maxRecent;

  final List<Duration> _recent = <Duration>[];
  var _listening = false;

  int get recentJankCount => _recent.length;

  List<Duration> get recentJanks => List.unmodifiable(_recent);

  bool get isEnabled =>
      remoteConfig.isFeatureEnabled('jank_monitor_enabled', defaultValue: true);

  void start() {
    if (_listening) return;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _listening = true;
  }

  void stop() {
    if (!_listening) return;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _listening = false;
  }

  void reset() => _recent.clear();

  /// Demo helper: record a jank sample without waiting for FrameTiming flush.
  void recordSyntheticJank({
    required int buildMs,
    required int rasterMs,
  }) {
    final total = Duration(milliseconds: buildMs + rasterMs);
    _recent.add(total);
    if (_recent.length > maxRecent) {
      _recent.removeAt(0);
    }
    appEvents.jankDetected(buildMs: buildMs, rasterMs: rasterMs);
  }

  void _onTimings(List<FrameTiming> timings) {
    if (!isEnabled) return;
    for (final t in timings) {
      final total = t.totalSpan;
      if (total < threshold) continue;
      _recent.add(total);
      if (_recent.length > maxRecent) {
        _recent.removeAt(0);
      }
      // Fire-and-forget; avoid awaiting on the frame callback.
      appEvents.jankDetected(
        buildMs: t.buildDuration.inMilliseconds,
        rasterMs: t.rasterDuration.inMilliseconds,
      );
    }
  }
}
