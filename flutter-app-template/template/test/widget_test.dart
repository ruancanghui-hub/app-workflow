import 'package:app_template/app/routes/app_routes.dart';
import 'package:app_template/core/env/app_environment.dart';
import 'package:app_template/core/http/http_client.dart';
import 'package:app_template/core/identity/app_instance_identity.dart';
import 'package:app_template/core/logging/app_logger.dart';
import 'package:app_template/core/ops/analytics.dart';
import 'package:app_template/core/ops/app_events.dart';
import 'package:app_template/core/ops/crash_reporter.dart';
import 'package:app_template/core/ops/jank_monitor.dart';
import 'package:app_template/core/ops/remote_config.dart';
import 'package:app_template/core/ops_console/ops_console_reporter.dart';
import 'package:app_template/core/storage/key_value_store.dart';
import 'package:app_template/core/theme/app_tokens.dart';
import 'package:app_template/features/catalog/catalog_binding.dart';
import 'package:app_template/features/catalog/catalog_page.dart';
import 'package:app_template/features/home/home_binding.dart';
import 'package:app_template/features/home/pages/home_page.dart';
import 'package:app_template/features/onboarding/onboarding_binding.dart';
import 'package:app_template/features/onboarding/onboarding_page.dart';
import 'package:app_template/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';

Widget _wrap(Widget child, {String initialRoute = AppRoutes.home, List<GetPage<dynamic>>? pages}) {
  final themeData = FTheme.neutral.light.touch;
  return GetMaterialApp(
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      ...FLocalizations.localizationsDelegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    theme: themeData.toApproximateMaterialTheme().copyWith(
          extensions: const [AppTokens.light],
        ),
    builder: (context, child) => FToaster(
      child: FTheme(
        data: themeData,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
    initialRoute: initialRoute,
    getPages: pages ??
        [
          GetPage(
            name: AppRoutes.home,
            page: HomePage.new,
            binding: HomeBinding(),
          ),
          GetPage(
            name: AppRoutes.catalog,
            page: CatalogPage.new,
            binding: CatalogBinding(),
          ),
        ],
  );
}

void main() {
  late FakeAnalytics analytics;

  setUp(() {
    Get.reset();
    analytics = FakeAnalytics();
    Get.put<AppEnvironment>(FakeAppEnvironment(BuildVariant.dev));
    Get.put<Analytics>(analytics);
    Get.put<RemoteConfig>(
      FakeRemoteConfig({
        'demo_flag': true,
        'jank_monitor_enabled': true,
      }),
    );
    Get.put<CrashReporter>(FakeCrashReporter());
    Get.put<HttpClient>(FakeHttpClient());
    Get.put<KeyValueStore>(FakeKeyValueStore());
    Get.put<AppLogger>(ConsoleAppLogger(forwardErrors: false));
    Get.put<AppInstanceIdentity>(
      const AppInstanceIdentity(appId: 't', displayName: 'T'),
    );
    Get.put<OpsConsoleReporter>(
      FakeOpsConsoleReporter(
        const AppInstanceIdentity(appId: 't', displayName: 'T'),
      ),
    );
    final appEvents = AppEvents(analytics);
    Get.put<AppEvents>(appEvents);
    Get.put<JankMonitor>(
      JankMonitor(
        appEvents: appEvents,
        remoteConfig: Get.find<RemoteConfig>(),
      ),
    );
  });

  tearDown(Get.reset);

  testWidgets('GetX home route shows catalog CTA and variant', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Open catalog'), findsOneWidget);
    expect(find.textContaining('dev'), findsOneWidget);
  });

  testWidgets('catalog page shows Buttons section and AppButton', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        const SizedBox.shrink(),
        initialRoute: AppRoutes.catalog,
        pages: [
          GetPage(
            name: AppRoutes.catalog,
            page: CatalogPage.new,
            binding: CatalogBinding(),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Capability catalog'), findsOneWidget);
    expect(find.text('Splash & Onboarding'), findsOneWidget);
    expect(find.text('Preview splash'), findsOneWidget);
    expect(find.text('Accordion'), findsOneWidget);
    expect(find.text('What is this?'), findsOneWidget);
    expect(find.text('Open pull-to-refresh page'), findsOneWidget);
  });

  testWidgets('onboarding page shows first slide', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox.shrink(),
        initialRoute: AppRoutes.catalogOnboarding,
        pages: [
          GetPage(
            name: AppRoutes.catalogOnboarding,
            page: OnboardingPage.new,
            binding: OnboardingBinding(preview: true),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('A solid foundation'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    expect(find.text('Next'), findsOneWidget);
  });
}
