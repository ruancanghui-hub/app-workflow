import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../tabs/home/home_tab_page.dart';
import '../../tabs/meditation/meditation_tab_page.dart';
import '../../tabs/sleep/sleep_tab_page.dart';
import '../../tabs/sound/sound_tab_page.dart';
import '../root_shell_controller.dart';

class RootShellPage extends GetView<RootShellController> {
  const RootShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final active = controller.activeTab.value;
        return IndexedStack(
          index: HealingRootTab.ordered.indexOf(active),
          sizing: StackFit.expand,
          children: [
            HomeTabPage(activeTab: active, onTabSelected: controller.requestTab),
            SleepTabPage(
              activeTab: active,
              onTabSelected: controller.requestTab,
            ),
            MeditationTabPage(
              activeTab: active,
              onTabSelected: controller.requestTab,
            ),
            SoundTabPage(
              activeTab: active,
              onTabSelected: controller.requestTab,
            ),
          ],
        );
      }),
    );
  }
}
