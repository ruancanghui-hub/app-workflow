import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 被检页面：名称 + 打开方式（负责 pumpWidget 并导航到该页）。
class QualityScreen {
  const QualityScreen(this.name, this.open);

  final String name;
  final Future<void> Function(WidgetTester tester) open;
}

/// 以 iPhone 15 Pro 尺寸渲染（1179×2556 px，3x）。
void usePhoneViewport(
  WidgetTester tester, {
  Size physicalSize = const Size(1179, 2556),
  double devicePixelRatio = 3,
}) {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);
}

void useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// 可点元素有标签、iOS ≥44pt、文字对比度 ≥4.5:1。调用前需 `tester.ensureSemantics()`。
Future<void> expectAccessibilityGuidelines(
  WidgetTester tester, {
  bool contrast = true,
}) async {
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  if (contrast) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
}

final _sourcePattern = RegExp(r'lib/[\w/]+\.dart:\d+');

/// 运行 [body] 期间收集全部 Flutter 错误（溢出等），每条带 `lib/...dart:行号`。
Future<List<String>> collectLayoutErrors(Future<void> Function() body) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final source =
        _sourcePattern.firstMatch(details.toString())?.group(0) ?? 'unknown';
    final message = details.exceptionAsString().split('\n').first;
    errors.add('$message @ $source');
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

/// 按合法顺序切到后台：resumed → inactive → hidden → paused。
Future<void> sendToBackground(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pumpAndSettle();
}

/// 按合法顺序回到前台：paused → hidden → inactive → resumed。
Future<void> bringToForeground(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pumpAndSettle();
}

/// 为每个页面生成：无障碍指南 ×1，动态字体 ×[textScales]。
void defineQualityTests(
  List<QualityScreen> screens, {
  List<double> textScales = const [1.35, 2.0],
  bool checkContrast = true,
}) {
  group('无障碍指南', () {
    for (final screen in screens) {
      testWidgets('${screen.name}：可点元素有标签、≥44pt、对比度达标', (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          usePhoneViewport(tester);
          await screen.open(tester);
          await expectAccessibilityGuidelines(tester, contrast: checkContrast);
        } finally {
          semantics.dispose();
        }
      });
    }
  });

  group('动态字体', () {
    for (final scale in textScales) {
      for (final screen in screens) {
        testWidgets('${screen.name}：字号 ×$scale 无溢出', (tester) async {
          usePhoneViewport(tester);
          useTextScale(tester, scale);
          final errors = await collectLayoutErrors(() => screen.open(tester));
          expect(errors, isEmpty, reason: errors.join('\n'));
        });
      }
    }
  });
}
