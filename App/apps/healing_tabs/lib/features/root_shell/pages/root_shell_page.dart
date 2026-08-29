import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../tabs/home/home_tab_page.dart';
import '../../tabs/meditation/meditation_tab_page.dart';
import '../../tabs/sleep/sleep_tab_page.dart';
import '../../tabs/sound/sound_tab_page.dart';
import '../root_shell_controller.dart';
import '../widgets/design_canvas.dart';

class RootShellPage extends GetView<RootShellController> {
  const RootShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Obx(() {
            final active = controller.activeTab.value;
            return DesignCanvas(
              child: IndexedStack(
                index: HealingRootTab.ordered.indexOf(active),
                children: [
                  HomeTabPage(
                    activeTab: active,
                    onTabSelected: controller.selectTab,
                  ),
                  SleepTabPage(
                    activeTab: active,
                    onTabSelected: controller.selectTab,
                  ),
                  MeditationTabPage(
                    activeTab: active,
                    onTabSelected: controller.selectTab,
                  ),
                  SoundTabPage(
                    activeTab: active,
                    onTabSelected: controller.selectTab,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
