import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';

import 'app/injection/app_bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/ops/jank_monitor.dart';
import 'core/storage/shared_preferences_store.dart';
import 'core/theme/app_tokens.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kv = await SharedPreferencesKeyValueStore.create();
  final bindings = AppBindings(keyValueStore: kv);
  bindings.dependencies();
  await AppBindings.wireAnalyticsAdapters();
  Get.find<JankMonitor>().start();
  runApp(const AppTemplateApp());
}

class AppTemplateApp extends StatelessWidget {
  const AppTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = FTheme.neutral.light.touch;

    return GetMaterialApp(
      title: 'App Template',
      theme: themeData.toApproximateMaterialTheme().copyWith(
            extensions: const [AppTokens.light],
          ),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => FTheme(
        data: themeData,
        child: FToaster(
          child: FTooltipGroup(child: child ?? const SizedBox.shrink()),
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
