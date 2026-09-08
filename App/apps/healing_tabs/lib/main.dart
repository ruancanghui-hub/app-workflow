import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/injection/app_bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/audio/healing_audio_handler.dart';
import 'core/storage/shared_preferences_store.dart';
import 'core/theme/app_tokens.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kv = await SharedPreferencesKeyValueStore.create();
  final bindings = AppBindings(keyValueStore: kv);
  bindings.dependencies();

  // Firebase / 广告 SDK 延后到用户同意隐私政策之后（见 LaunchPage / PrivacyConsentPage）。

  final audioHandler = await initHealingAudioService();
  Get.put<HealingAudioHandler>(audioHandler, permanent: true);

  runApp(const AppTemplateApp());
}

class AppTemplateApp extends StatelessWidget {
  const AppTemplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '云遥',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTokens.light.colorAccent,
        ),
        extensions: const [AppTokens.light],
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.launch,
      getPages: AppPages.pages,
    );
  }
}
