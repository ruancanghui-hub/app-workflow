import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/assets/healing_assets.dart';
import '../../core/audio/app_audio_coordinator.dart';
import '../../domain/models/meditation_content.dart';
import '../../domain/models/sleep_content.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/health_data_repository.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../content_catalog/pages/content_category_list_page.dart';
import '../device/rest_data_controller.dart';
import '../player/player_launch_args.dart';
import '../root_shell/root_shell_controller.dart';
import '../sleep_session/sleep_report_builder.dart';
import '../sleep_session/sleep_session_controller.dart';
import '../sleep_session/widgets/sleep_health_connect_sheet.dart';
import '../sleep_session/widgets/sleep_start_sheet.dart';
import '../tabs/home/home_scene_catalog.dart';
import '../tabs/home/home_scene_controller.dart';
import '../tabs/meditation/meditation_content_catalog.dart';
import '../tabs/sleep/sleep_content_catalog.dart';

void _ensureSleepSessionController() {
  if (!Get.isRegistered<SleepSessionController>()) {
    Get.put(
      SleepSessionController(sleepRepository: Get.find<SleepRepository>()),
      permanent: true,
    );
  }
}

void openPlayer(
  String soundId, {
  String scenario = 'sleep',
  String? coverImageAsset,
  String? displayTitle,
  String? displaySubtitle,
  int? countdownMinutes,
  bool autoPlay = false,
}) {
  Get.toNamed(
    '${AppRoutes.player}/$soundId',
    parameters: {'scenario': scenario},
    arguments: PlayerLaunchArgs(
      coverImageAsset: coverImageAsset,
      displayTitle: displayTitle,
      displaySubtitle: displaySubtitle,
      countdownMinutes: countdownMinutes,
      autoPlay: autoPlay,
    ),
  );
}

Future<void> openFocusSession({
  required String soundId,
  required int minutes,
}) async {
  String title = soundId;
  String subtitle = '心流专注';
  String? cover;
  for (final scene in HomeSceneCatalog.scenes) {
    if (scene.id == soundId) {
      title = scene.title;
      subtitle = scene.copy;
      cover = scene.backgroundAsset;
      break;
    }
  }
  openPlayer(
    soundId,
    scenario: 'meditation',
    coverImageAsset: cover,
    displayTitle: title,
    displaySubtitle: subtitle,
    countdownMinutes: minutes.clamp(3, 180),
    autoPlay: true,
  );
}

void openNowPlayingPlayer() {
  if (!Get.isRegistered<AppAudioCoordinator>()) return;
  final audio = Get.find<AppAudioCoordinator>();
  final soundId = audio.activeContentId.value;
  if (soundId == null || soundId.isEmpty) return;
  openPlayer(
    soundId,
    coverImageAsset: audio.nowPlayingCover.value,
    displayTitle: audio.nowPlayingTitle.value,
    displaySubtitle: audio.nowPlayingSubtitle.value,
  );
}

void openSleepFeatured(SleepFeaturedItem item) {
  openPlayer(
    item.soundId,
    coverImageAsset: item.coverImageAsset,
    displayTitle: item.title,
    displaySubtitle: item.subtitle,
  );
}

Future<void> openHomeScene(String sceneId, {bool autoplay = false}) async {
  await Get.find<RootShellController>().requestTab(HealingRootTab.home);
  await Get.find<HomeSceneController>().goToScene(sceneId, autoplay: autoplay);
}

void openBreath({int? minutes}) {
  Get.toNamed(
    AppRoutes.breath,
    arguments: minutes,
  );
}

void openSleepPicker({bool forCompanion = false}) {
  Get.toNamed(
    AppRoutes.sleepPicker,
    parameters: forCompanion ? {'companion': '1'} : const {},
  );
}

void openSleepContent(SleepContentItem item) {
  final soundId = item.soundId ??
      SleepContentCatalog.categories.first.items.first.soundId ??
      'valley_rain';
  openPlayer(
    soundId,
    coverImageAsset: item.coverImageAsset,
    displayTitle: item.title,
    displaySubtitle: item.subtitle,
  );
}

void openMeditationFeatured(MeditationFeaturedItem item) {
  openPlayer(
    item.soundId,
    scenario: 'meditation',
    coverImageAsset: item.coverImageAsset,
    displayTitle: item.title,
    displaySubtitle: item.subtitle,
  );
}

void openMeditationContent(MeditationContentItem item) {
  final soundId = item.soundId ??
      MeditationContentCatalog.categories.first.items.first.soundId ??
      'valley_rain';
  openPlayer(
    soundId,
    scenario: 'meditation',
    coverImageAsset: item.coverImageAsset,
    displayTitle: item.title,
    displaySubtitle: item.subtitle,
  );
}

void openSleepCategory(String categoryId) {
  Get.toNamed(
    AppRoutes.contentCategoryList,
    arguments: ContentCategoryListArgs(tab: 'sleep', categoryId: categoryId),
  );
}

void openMeditationCategory(String categoryId) {
  Get.toNamed(
    AppRoutes.contentCategoryList,
    arguments: ContentCategoryListArgs(
      tab: 'meditation',
      categoryId: categoryId,
    ),
  );
}

void openMeditationPractice(int minutes) =>
    Get.toNamed(AppRoutes.meditationPractice, arguments: minutes);

void openSleepReport(SleepSession session) {
  Get.toNamed(AppRoutes.sleepReport, arguments: session);
}

void openMePage() => Get.toNamed(AppRoutes.me);

void openDeviceTab() {
  if (!HealingRootTab.showsRestTab) return;
  Get.find<RootShellController>().requestTab(HealingRootTab.device);
}

Future<void> openAppleHealthConnect() async {
  if (!Get.isRegistered<RestDataController>()) return;
  await Get.find<RestDataController>().connectAppleHealth();
}

void openDeviceTabForPairing() {
  openDeviceTab();
  unawaited(openAppleHealthConnect());
}

/// 睡前放松 / 休息报告主入口。
Future<void> openSleepMonitoring({bool preferReport = false}) async {
  if (!Platform.isIOS) return;
  final context = Get.context;
  if (context == null) return;

  if (preferReport) {
    final rest = Get.isRegistered<RestDataController>()
        ? Get.find<RestDataController>()
        : null;
    if (rest == null || !rest.isConnected) {
      await showSleepHealthConnectSheet(context);
      return;
    }
    final health = Get.find<HealthDataRepository>();
    final night = await health.nightSleep(SleepDay.startOf(DateTime.now()));
    if (night != null) {
      openSleepReport(SleepReportBuilder.fromHealth(night));
      return;
    }
    await Get.toNamed(AppRoutes.sleepReport);
    return;
  }

  _ensureSleepSessionController();
  final repo = Get.find<SleepRepository>();
  final active = await repo.activeSession();

  if (active != null) {
    await Get.find<SleepSessionController>().restoreActive();
    await Get.toNamed(AppRoutes.sleepSession);
    return;
  }

  final sheetContext = Get.context;
  if (sheetContext == null) return;
  await showSleepStartSheet(sheetContext);
}

void openRingSleepReport() => openSleepMonitoring(preferReport: true);

void openHeartRateTrend() {
  if (!Platform.isIOS) return;
  final rest = Get.isRegistered<RestDataController>()
      ? Get.find<RestDataController>()
      : null;
  if (rest == null || !rest.isConnected) {
    final context = Get.context;
    if (context != null) {
      unawaited(showSleepHealthConnectSheet(context));
    }
    return;
  }
  Get.toNamed(AppRoutes.heartRateTrend);
}

Future<void> openSleepSession({String? soundId}) async {
  final context = Get.context;
  if (context == null) return;

  _ensureSleepSessionController();
  await Get.find<SleepSessionController>().start(soundId: soundId);
  await Get.toNamed(AppRoutes.sleepSession);
}
