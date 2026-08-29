enum HealingRootTab {
  home,
  sleep,
  meditation,
  sound;

  String get label => switch (this) {
        HealingRootTab.home => '首页',
        HealingRootTab.sleep => '睡眠',
        HealingRootTab.meditation => '冥想',
        HealingRootTab.sound => '声音',
      };

  String get assetKey => name;

  static const ordered = [
    HealingRootTab.home,
    HealingRootTab.sleep,
    HealingRootTab.meditation,
    HealingRootTab.sound,
  ];
}

abstract final class HealingAssets {
  static String background(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/backgrounds/background_${tab.assetKey}.png';

  static String navIcon(HealingRootTab screenTab, HealingRootTab iconTab) =>
      'assets/images/${screenTab.assetKey}/nav_icons/nav_${iconTab.assetKey}.png';

  static String profileOrb(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/status/profile_orb.png';

  static String playButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/play_button.png';

  static String searchButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/search_button.png';

  static String addButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/add_button.png';
}
