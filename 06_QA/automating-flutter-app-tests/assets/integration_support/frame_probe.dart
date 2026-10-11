import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qa_log.dart';

/// 持续 pump [duration]，用于等待真实插件与动画（pumpAndSettle 遇到无限动画会超时）。
Future<void> settleFor(
  WidgetTester tester,
  Duration duration, {
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
  }
}

/// 按动作统计帧耗时，每个动作输出一行 `QA perf <动作>: ...`。
class FrameProbe {
  FrameProbe(this.tester);

  final WidgetTester tester;
  final List<FrameTiming> _all = [];

  List<FrameTiming> get all => List.unmodifiable(_all);

  Future<List<FrameTiming>> measure(
    String action,
    Future<void> Function() body, {
    Duration settle = const Duration(milliseconds: 400),
  }) async {
    final timings = <FrameTiming>[];
    void collect(List<FrameTiming> batch) => timings.addAll(batch);
    SchedulerBinding.instance.addTimingsCallback(collect);
    try {
      await body();
      await settleFor(tester, settle);
    } finally {
      SchedulerBinding.instance.removeTimingsCallback(collect);
    }
    _all.addAll(timings);
    QaLog.perf(action, timings);
    return timings;
  }

  void reportTotal() => QaLog.perf('合计', _all);
}
