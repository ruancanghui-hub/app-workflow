// L1 组件质量测试示例。拷到 <app>/test/app_quality_test.dart，然后：
// 1. 把 _DemoApp 换成 App 根组件（注入测试数据与假服务，参考 test/support 下已有的 fake）；
// 2. 把 _screens 换成 App 的全部 P0 页面（Tab 页 + 二级页）；
// 3. 把 VoiceOver / 中断 / 弱网用例改成 App 主路径上的真实控件与端口。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/quality_harness.dart';

Future<void> _openHome(WidgetTester tester) async {
  await tester.pumpWidget(const _DemoApp());
  await tester.pumpAndSettle();
}

final _screens = <QualityScreen>[
  const QualityScreen('首页', _openHome),
  QualityScreen('详情页', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();
  }),
];

void main() {
  defineQualityTests(_screens);

  testWidgets('VoiceOver：主按钮有标签、按钮语义与点按动作', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _openHome(tester);
      expect(
        tester.getSemantics(find.text('查看详情')),
        isSemantics(label: '查看详情', isButton: true, hasTapAction: true),
      );
    } finally {
      semantics.dispose();
    }
  });

  group('弱网与中断', () {
    testWidgets('输入中切到后台再回来，内容保留', (tester) async {
      await _openHome(tester);
      await tester.enterText(find.byType(TextField), '未保存的草稿');
      await sendToBackground(tester);
      await bringToForeground(tester);
      expect(find.text('未保存的草稿'), findsOneWidget);
    });

    testWidgets('加载失败时显示错误态与重试', (tester) async {
      await tester.pumpWidget(const _DemoApp(offline: true));
      await tester.pumpAndSettle();
      expect(find.text('网络不可用'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });
  });
}

class _DemoApp extends StatelessWidget {
  const _DemoApp({this.offline = false});

  final bool offline;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _HomePage(offline: offline));
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.offline});

  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (offline) ...[
            const Text('网络不可用'),
            TextButton(onPressed: () {}, child: const Text('重试')),
          ],
          const TextField(decoration: InputDecoration(labelText: '备注')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const _DetailPage()),
            ),
            child: const Text('查看详情'),
          ),
        ],
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('详情')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('这是一段需要在大字号下完整换行显示的说明文字。'),
      ),
    );
  }
}
