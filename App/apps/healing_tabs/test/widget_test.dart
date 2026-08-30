import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:healing_tabs/app/routes/app_routes.dart';
import 'package:healing_tabs/core/env/app_environment.dart';
import 'package:healing_tabs/core/http/http_client.dart';
import 'package:healing_tabs/core/identity/app_instance_identity.dart';
import 'package:healing_tabs/core/logging/app_logger.dart';
import 'package:healing_tabs/core/ops/analytics.dart';
import 'package:healing_tabs/core/ops/crash_reporter.dart';
import 'package:healing_tabs/core/ops/remote_config.dart';
import 'package:healing_tabs/core/ops_console/ops_console_reporter.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/core/theme/app_tokens.dart';
import 'package:healing_tabs/features/root_shell/pages/root_shell_page.dart';
import 'package:healing_tabs/features/root_shell/root_shell_binding.dart';
import 'package:healing_tabs/features/tabs/home/home_greeting_copy.dart';
import 'package:healing_tabs/l10n/app_localizations.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put<AppEnvironment>(FakeAppEnvironment(BuildVariant.dev));
    Get.put<Analytics>(FakeAnalytics());
    Get.put<RemoteConfig>(FakeRemoteConfig({'demo_flag': true}));
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
  });

  tearDown(Get.reset);

  testWidgets('root shell shows home tab title', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        theme: ThemeData(extensions: const [AppTokens.light]),
        initialRoute: AppRoutes.home,
        getPages: [
          GetPage(
            name: AppRoutes.home,
            page: RootShellPage.new,
            binding: RootShellBinding(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(HomeGreetingCopy.title(DateTime.now())), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
  });
}
