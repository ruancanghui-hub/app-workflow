import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/injection/app_bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/ads/app_open_ad_manager.dart';
import 'core/audio/healing_audio_handler.dart';
import 'core/storage/shared_preferences_store.dart';
import 'core/theme/app_tokens.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kv = await SharedPreferencesKeyValueStore.create();
  final bindings = AppBindings(keyValueStore: kv);
  bindings.dependencies();
  await AppBindings.wireFirebaseAdapters();

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    final openAds = Get.put(AppOpenAdManager(), permanent: true);
    unawaited(openAds.loadAd());
  }

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
