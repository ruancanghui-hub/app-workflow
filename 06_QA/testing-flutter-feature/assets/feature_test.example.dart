// 复制到 <app>/test/<feature>_test.dart，替换 import、FeaturePage 与断言文案。
// 规则：测试失败就修 App 代码，不放宽断言。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/feature/pages/feature_page.dart';

Future<void> pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('main path: primary action shows the result', (tester) async {
    await pumpPage(tester, const FeaturePage());

    expect(find.text('页面标题'), findsOneWidget);

    final action = find.bySemanticsLabel('主操作');
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('操作结果'), findsOneWidget);
  });

  testWidgets('empty state is explained', (tester) async {
    await pumpPage(tester, const FeaturePage());

    expect(find.text('暂无内容'), findsOneWidget);
  });

  testWidgets('text inside a list is matched without the input field', (
    tester,
  ) async {
    await pumpPage(tester, const FeaturePage());

    await tester.enterText(find.byType(TextField), '关键词');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListView, '关键词'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(ListView), matching: find.text('无关项')),
      findsNothing,
    );
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester, const FeaturePage());

    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
