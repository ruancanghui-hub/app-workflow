// L2 / L3 系统能力与性能探针示例。拷到 <app>/integration_test/qa_simulator_test.dart，然后改写 _hooks：
// - launch：调用 App 的 main()（先清空本地存储、跳过首次弹窗）；
// - firstScreen：首屏一定出现的文案；
// - notifications / saveToAlbum / startPurchase：接 App 自己的服务；不涉及的能力保持 null，报告记为 skip；
// - perfActions：主路径上的滚动、切 Tab、进出详情等动作。
// 运行：run_autotest.py 会以 QA_ALBUM=granted / denied 各跑一轮。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/frame_probe.dart';
import 'support/launch_probe.dart';
import 'support/qa_log.dart';

typedef PerfAction = ({String name, Future<void> Function(WidgetTester) run});

/// App 的系统能力接入点。
class QaHooks {
  const QaHooks({
    required this.launch,
    required this.firstScreen,
    required this.perfActions,
    this.notifications,
    this.saveToAlbum,
    this.startPurchase,
    this.purchaseBusy,
    this.storeTimeout = const Duration(seconds: 20),
  });

  final Future<void> Function() launch;
  final Finder firstScreen;
  final List<PerfAction> perfActions;

  /// 用真实插件排程后读取 iOS 待发队列，返回计划数与实际数。
  final Future<({int planned, int pending})> Function()? notifications;

  /// 写入一张图片到相册，返回是否写入成功。
  final Future<bool> Function()? saveToAlbum;

  /// 发起购买，返回是否已拉起支付；模拟器无商品时应返回 false。
  final Future<bool> Function()? startPurchase;

  /// 购买返回后界面是否仍处于忙碌态。
  final bool Function()? purchaseBusy;

  final Duration storeTimeout;
}

final _hooks = QaHooks(
  launch: () async => runApp(const _DemoApp()),
  firstScreen: find.text('今日'),
  perfActions: [
    (
      name: '列表滚动',
      run: (tester) async {
        for (var i = 0; i < 3; i++) {
          await tester.fling(find.byType(ListView), const Offset(0, -600), 2000);
          await tester.pumpAndSettle();
          await tester.fling(find.byType(ListView), const Offset(0, 600), 2000);
          await tester.pumpAndSettle();
        }
      },
    ),
    (
      name: '进出详情',
      run: (tester) async {
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.text('第 1 项'));
          await tester.pumpAndSettle();
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      },
    ),
  ],
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('模拟器 QA', (tester) async {
    final launch = LaunchProbe.start();
    await _hooks.launch();
    await launch.waitForFirstScreen(tester, _hooks.firstScreen);
    await settleFor(tester, const Duration(seconds: 1));

    final notifications = _hooks.notifications;
    if (notifications == null) {
      QaLog.skip('notifications', '本 App 无本地通知');
    } else {
      final result = await notifications();
      QaLog.notifications(planned: result.planned, pending: result.pending);
      expect(result.planned, greaterThan(0));
      expect(
        result.pending,
        result.planned,
        reason: 'pending=0 时先确认已用 applesimutils 授予通知权限',
      );
    }

    final saveToAlbum = _hooks.saveToAlbum;
    if (saveToAlbum == null) {
      QaLog.skip('album', '本 App 不写相册');
    } else {
      final saved = await saveToAlbum();
      QaLog.album(qaAlbumPermission, saved: saved);
      expect(saved, qaAlbumPermission == 'granted');
    }

    final startPurchase = _hooks.startPurchase;
    if (startPurchase == null) {
      QaLog.skip('store', '本 App 无内购');
    } else {
      final watch = Stopwatch()..start();
      final started = await startPurchase();
      QaLog.store(started: started, elapsed: watch.elapsed);
      expect(started, isFalse, reason: '模拟器无沙盒商品，应走不可购买降级');
      expect(watch.elapsed, lessThan(_hooks.storeTimeout));
      expect(_hooks.purchaseBusy?.call() ?? false, isFalse);
    }

    final probe = FrameProbe(tester);
    for (final action in _hooks.perfActions) {
      await probe.measure(action.name, () => action.run(tester));
    }
    probe.reportTotal();
    expect(probe.all, isNotEmpty);
  });
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('今日')),
        body: ListView.builder(
          itemCount: 60,
          itemBuilder: (context, index) => ListTile(
            title: Text('第 ${index + 1} 项'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text('第 ${index + 1} 项详情')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
