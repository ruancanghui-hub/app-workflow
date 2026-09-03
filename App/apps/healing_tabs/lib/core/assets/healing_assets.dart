enum HealingRootTab {
  home,
  sleep,
  meditation,
  device;

  String get label => switch (this) {
        HealingRootTab.home => '首页',
        HealingRootTab.sleep => '睡眠',
        HealingRootTab.meditation => '冥想',
        HealingRootTab.device => '戒指',
      };

  /// Asset folder key. Device reuses the former sound art pack until dedicated art ships.
  String get assetKey => switch (this) {
        HealingRootTab.device => 'sound',
        _ => name,
      };

  static const ordered = [
    HealingRootTab.home,
    HealingRootTab.sleep,
    HealingRootTab.meditation,
    HealingRootTab.device,
  ];
}

abstract final class HealingAssets {
  static String background(HealingRootTab tab) =>
      'assets/images/${tab.assetKey}/backgrounds/background_${tab.assetKey}.png';

  /// Shared bottom-tab glyphs (home / sleep / meditation / ring).
  /// Always read from `home/nav_icons` so every screen shows the same set.
  static String navIcon(HealingRootTab screenTab, HealingRootTab iconTab) =>
      'assets/images/home/nav_icons/nav_${iconTab.assetKey}.png';

  /// Compensates for inconsistent glyph padding inside nav icon assets.
  static double navIconVisualScale(HealingRootTab iconTab) => switch (iconTab) {
        HealingRootTab.home => 1.05,
        HealingRootTab.sleep => 1.08,
        HealingRootTab.meditation => 1.05,
        HealingRootTab.device => 1.1,
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
