import 'package:app_template/core/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  final themeData = FTheme.neutral.light.touch;
  return MaterialApp(
    theme: themeData.toApproximateMaterialTheme(),
    builder: (context, child) => FTheme(
      data: themeData,
      child: FToaster(child: child ?? const SizedBox.shrink()),
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AppButton loading disables press', (tester) async {
    await tester.pumpWidget(
      _host(
        AppButton(
          loading: true,
          onPress: () {},
          child: const Text('Go'),
        ),
      ),
    );
    await tester.pump();
    final button = tester.widget<FButton>(find.byType(FButton));
    expect(button.onPress, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('AppDialog.showConfirm returns true on confirm', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => AppButton(
            onPress: () async {
              result = await AppDialog.showConfirm(
                context,
                title: 'Sure?',
                message: 'Please confirm',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Sure?'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('AppRatingPrompt returns positive', (tester) async {
    AppRatingPromptResult? result;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => AppButton(
            onPress: () async {
              result = await AppRatingPrompt.show(
                context,
                title: 'Rate us',
                message: 'Please',
                positiveLabel: 'Good',
                negativeLabel: 'Bad',
                laterLabel: 'Later',
              );
            },
            child: const Text('OpenRating'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('OpenRating'));
    await tester.pumpAndSettle();
    expect(find.text('Rate us'), findsOneWidget);
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
    expect(result, AppRatingPromptResult.positive);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
