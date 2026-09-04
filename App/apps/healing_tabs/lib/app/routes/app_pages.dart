import 'package:get/get.dart';

import '../../features/breath/breath_binding.dart';
import '../../features/breath/pages/breath_page.dart';
import '../../features/device/pages/device_scan_page.dart';
import '../../features/me/pages/me_page.dart';
import '../../features/meditation/pages/meditation_practice_page.dart';
import '../../features/meditation/pages/meditation_summary_page.dart';
import '../../features/player/pages/player_page.dart';
import '../../features/player/player_binding.dart';
import '../../features/root_shell/pages/root_shell_page.dart';
import '../../features/root_shell/root_shell_binding.dart';
import '../../features/sleep_session/pages/sleep_picker_page.dart';
import '../../features/sleep_session/pages/sleep_report_page.dart';
import '../../features/sleep_session/pages/sleep_session_page.dart';
import '../../features/sleep_session/sleep_session_binding.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: RootShellPage.new,
      binding: RootShellBinding(),
    ),
    GetPage(
      name: '${AppRoutes.player}/:soundId',
      page: PlayerPage.new,
      binding: PlayerBinding(),
    ),
    GetPage(
      name: AppRoutes.sleepSession,
      page: SleepSessionPage.new,
      binding: SleepSessionBinding(),
    ),
    GetPage(name: AppRoutes.sleepReport, page: SleepReportPage.new),
    GetPage(name: AppRoutes.sleepPicker, page: SleepPickerPage.new),
    GetPage(
      name: AppRoutes.meditationPractice,
      page: MeditationPracticePage.new,
    ),
    GetPage(name: AppRoutes.meditationSummary, page: MeditationSummaryPage.new),
    GetPage(
      name: AppRoutes.breath,
      page: BreathPage.new,
      binding: BreathBinding(),
    ),
    GetPage(name: AppRoutes.me, page: MePage.new),
    GetPage(name: AppRoutes.deviceScan, page: DeviceScanPage.new),
  ];
}
