import 'package:get/get.dart';

import '../../core/assets/healing_assets.dart';

class RootShellController extends GetxController {
  final activeTab = HealingRootTab.home.obs;

  void selectTab(HealingRootTab tab) {
    activeTab.value = tab;
  }
}
