import 'dart:ui';

import 'package:flutter/foundation.dart';

/// 相册权限场景，由 `simctl privacy` 预置后通过 `--dart-define=QA_ALBUM=granted|denied` 告知。
const qaAlbumPermission = String.fromEnvironment(
  'QA_ALBUM',
  defaultValue: 'granted',
);

/// `QA ...` 输出行。格式是 run_autotest.py 的解析契约，修改时两边同步。
abstract final class QaLog {
  static void firstScreen(Duration elapsed) =>
      _emit('first screen: ${elapsed.inMilliseconds} ms');

  static void perf(String action, List<FrameTiming> timings) =>
      _emit('perf $action: ${summarizeFrames(timings)}');

  static void notifications({required int planned, required int pending}) =>
      _emit('notifications planned=$planned pending=$pending');

  static void album(String permission, {required bool saved}) =>
      _emit('album($permission) -> ${saved ? 'saved' : 'denied'}');

  static void store({required bool started, required Duration elapsed}) =>
      _emit('store buy started=$started in ${elapsed.inMilliseconds} ms');

  static void timing(String label, Duration elapsed) =>
      _emit('timing $label: ${elapsed.inMilliseconds} ms');

  static void skip(String item, String reason) => _emit('skip $item: $reason');

  static void _emit(String line) => debugPrint('QA $line');
}

/// `frames=… build p50=… p90=… max=…ms; raster p90=… max=…ms; over16ms=…`
String summarizeFrames(List<FrameTiming> timings) {
  if (timings.isEmpty) return 'no frames';
  double ms(Duration d) => d.inMicroseconds / 1000;
  final build = [for (final t in timings) ms(t.buildDuration)]..sort();
  final raster = [for (final t in timings) ms(t.rasterDuration)]..sort();
  double p(List<double> list, double q) =>
      list[((list.length - 1) * q).round()];
  String f(double v) => v.toStringAsFixed(1);
  final over = timings
      .where(
        (t) =>
            t.buildDuration + t.rasterDuration >
            const Duration(milliseconds: 16),
      )
      .length;
  return 'frames=${timings.length} '
      'build p50=${f(p(build, .5))} p90=${f(p(build, .9))} '
      'max=${f(build.last)}ms; '
      'raster p90=${f(p(raster, .9))} max=${f(raster.last)}ms; '
      'over16ms=$over';
}
