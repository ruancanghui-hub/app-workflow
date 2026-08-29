import 'package:get/get.dart';

import '../../features/root_shell/pages/root_shell_page.dart';
import '../../features/root_shell/root_shell_binding.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: RootShellPage.new,
      binding: RootShellBinding(),
    ),
  ];
}
