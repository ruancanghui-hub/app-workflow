import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/assets/healing_assets.dart';
import '../../domain/models/meditation_content.dart';
import '../../domain/models/sleep_content.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../player/player_launch_args.dart';
import '../root_shell/root_shell_controller.dart';
import '../sleep_session/sleep_session_controller.dart';
import '../tabs/home/home_scene_controller.dart';
import '../tabs/meditation/meditation_content_catalog.dart';
import '../tabs/sleep/sleep_content_catalog.dart';

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

void openSleepPicker() => Get.toNamed(AppRoutes.sleepPicker);

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

/// 从戒指 Tab 打开昨夜睡眠报告（监测摘要详情，非节目内容）。
void openRingSleepReport() {
  final now = DateTime.now();
  final wake = DateTime(now.year, now.month, now.day, 7, 12);
  final start = wake.subtract(const Duration(hours: 7, minutes: 42));
  openSleepReport(
    SleepSession(
      id: 'ring-last-night',
      startedAt: start,
      endedAt: wake,
      status: SleepSessionStatus.completed,
      rating: 4,
    ),
  );
}

void openMePage() => Get.toNamed(AppRoutes.me);

void openDeviceTab() {
  Get.find<RootShellController>().requestTab(HealingRootTab.device);
}

Future<void> openSleepSession({String? soundId}) async {
  if (!Get.isRegistered<SleepSessionController>()) {
    Get.put(
      SleepSessionController(sleepRepository: Get.find<SleepRepository>()),
      permanent: true,
    );
  }
  await Get.find<SleepSessionController>().start(soundId: soundId);
  await Get.toNamed(AppRoutes.sleepSession);
}
