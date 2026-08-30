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

  /// Compensates for inconsistent glyph padding inside nav icon assets.
  static double navIconVisualScale(HealingRootTab iconTab) => switch (iconTab) {
        HealingRootTab.home => 1.08,
        HealingRootTab.sleep => 1.37,
        HealingRootTab.meditation => 1.0,
        HealingRootTab.sound => 1.0,
      };

  static String profileOrb(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/status/profile_orb.png';

  static String playButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/play_button.png';

  static String searchButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/search_button.png';

  static String addButton(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/ui_controls/add_button.png';
}
