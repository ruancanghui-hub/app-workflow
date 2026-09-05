import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../tabs/device/device_tab_page.dart';
import '../../tabs/home/home_tab_page.dart';
import '../../tabs/meditation/meditation_tab_page.dart';
import '../../tabs/sleep/sleep_tab_page.dart';
import '../root_shell_controller.dart';
import '../widgets/animated_tab_layer.dart';
import '../widgets/healing_tab_bar.dart';
import '../widgets/now_playing_bar.dart';

class RootShellPage extends GetView<RootShellController> {
  const RootShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final active = controller.activeTab.value;
        final activeIndex = HealingRootTab.ordered.indexOf(active);

        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < HealingRootTab.ordered.length; i++)
              if (HealingRootTab.ordered[i] == active ||
                  controller.visitedTabs.contains(HealingRootTab.ordered[i]))
                AnimatedTabLayer(
                  visible: HealingRootTab.ordered[i] == active,
                  tabIndex: i,
                  activeIndex: activeIndex,
                  child: _tabPage(HealingRootTab.ordered[i], active),
                ),
            const NowPlayingBar(),
            HealingTabBar(
              screenTab: active,
              activeTab: active,
              onTabSelected: controller.requestTab,
              layout: HealingTabBarLayout.docked,
            ),
          ],
        );
      }),
    );
  }

  Widget _tabPage(HealingRootTab tab, HealingRootTab active) {
    return switch (tab) {
      HealingRootTab.home => HomeTabPage(
          activeTab: active,
          onTabSelected: controller.requestTab,
        ),
      HealingRootTab.sleep => SleepTabPage(
          activeTab: active,
          onTabSelected: controller.requestTab,
        ),
      HealingRootTab.meditation => MeditationTabPage(
          activeTab: active,
          onTabSelected: controller.requestTab,
        ),
      HealingRootTab.device => DeviceTabPage(
          activeTab: active,
          onTabSelected: controller.requestTab,
        ),
    };
  }
}
