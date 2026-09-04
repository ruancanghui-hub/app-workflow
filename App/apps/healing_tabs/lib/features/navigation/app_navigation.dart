import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/assets/healing_assets.dart';
import '../../domain/models/meditation_content.dart';
import '../../domain/models/sleep_content.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../device/device_connection_controller.dart';
import '../player/player_launch_args.dart';
import '../root_shell/root_shell_controller.dart';
import '../sleep_session/sleep_report_builder.dart';
import '../sleep_session/sleep_session_controller.dart';
import '../sleep_session/widgets/sleep_monitoring_pairing_sheet.dart';
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
}) {
  Get.toNamed(
    '${AppRoutes.player}/$soundId',
    parameters: {'scenario': scenario},
    arguments: PlayerLaunchArgs(
      coverImageAsset: coverImageAsset,
      displayTitle: displayTitle,
      displaySubtitle: displaySubtitle,
    ),
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

/// 从声景库跳转到首页指定场景；[autoplay] 为 true 时同时开启环境声。
Future<void> openHomeScene(String sceneId, {bool autoplay = false}) async {
  await Get.find<RootShellController>().requestTab(HealingRootTab.home);
  await Get.find<HomeSceneController>().goToScene(sceneId, autoplay: autoplay);
}

void openBreath() => Get.toNamed(AppRoutes.breath);

void openSleepPicker({bool forCompanion = false}) {
  Get.toNamed(
    AppRoutes.sleepPicker,
    parameters: forCompanion ? {'companion': '1'} : const {},
  );
}

void openSleepContent(SleepContentItem item) {
  final soundId = item.soundId ?? SleepContentCatalog.soundForIndex(0);
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
  final soundId = item.soundId ?? MeditationContentCatalog.soundForIndex(0);
  openPlayer(
    soundId,
    scenario: 'meditation',
    coverImageAsset: item.coverImageAsset,
    displayTitle: item.title,
    displaySubtitle: item.subtitle,
  );
}

void openMeditationPractice(int minutes) =>
    Get.toNamed(AppRoutes.meditationPractice, arguments: minutes);

void openSleepReport(SleepSession session) {
  Get.toNamed(AppRoutes.sleepReport, arguments: session);
}

void openMePage() => Get.toNamed(AppRoutes.me);

void openDeviceTab() {
  Get.find<RootShellController>().requestTab(HealingRootTab.device);
}

Future<void> openDeviceSearch() async {
  await Get.toNamed(AppRoutes.deviceScan);
}

void openDeviceTabForPairing() {
  unawaited(openDeviceSearch());
}

/// 睡眠监测主入口：配对拦截 → 进行中会话 / 开始页 / 昨夜报告。
Future<void> openSleepMonitoring({bool preferReport = false}) async {
  final context = Get.context;
  if (context == null) return;

  final device = Get.find<DeviceConnectionController>();
  if (!device.isPaired) {
    await showSleepMonitoringPairingSheet(context);
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

  if (preferReport) {
    final history = await repo.listHistory();
    if (history.isNotEmpty) {
      openSleepReport(history.first);
      return;
    }
    final summary = device.snapshot.sleep;
    if (summary != null) {
      openSleepReport(SleepReportBuilder.fromSummary(summary));
      return;
    }
  }

  await Get.toNamed(AppRoutes.sleepSession);
}

void openRingSleepReport() => openSleepMonitoring(preferReport: true);

Future<void> openSleepSession({String? soundId}) async {
  final context = Get.context;
  if (context == null) return;

  final device = Get.find<DeviceConnectionController>();
  if (!device.isPaired) {
    await showSleepMonitoringPairingSheet(context);
    return;
  }

  _ensureSleepSessionController();
  await Get.find<SleepSessionController>().start(soundId: soundId);
  await Get.toNamed(AppRoutes.sleepSession);
}
