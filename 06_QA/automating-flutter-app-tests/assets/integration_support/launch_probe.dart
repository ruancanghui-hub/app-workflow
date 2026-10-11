import 'package:flutter_test/flutter_test.dart';

import 'qa_log.dart';

/// 启动计时：在调用 `app.main()` 之前 [LaunchProbe.start]，首屏出现后输出 `QA first screen`。
class LaunchProbe {
  LaunchProbe.start() : _watch = Stopwatch()..start();

  final Stopwatch _watch;

  Future<Duration> waitForFirstScreen(
    WidgetTester tester,
    Finder firstScreen, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 20),
  }) async {
    while (firstScreen.evaluate().isEmpty && _watch.elapsed < timeout) {
      await tester.pump(step);
    }
    final elapsed = _watch.elapsed;
    QaLog.firstScreen(elapsed);
    expect(
      firstScreen,
      findsWidgets,
      reason: '首屏 ${timeout.inSeconds}s 内未出现',
    );
    return elapsed;
  }
}

/// 计时任意异步动作并输出 `QA timing <label>: <ms> ms`，如导出渲染。
Future<T> timeQa<T>(String label, Future<T> Function() action) async {
  final watch = Stopwatch()..start();
  final result = await action();
  QaLog.timing(label, watch.elapsed);
  return result;
}
