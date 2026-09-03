/// 播放器页面启动参数（不走 URL，避免中文路径编码错误）。
class PlayerLaunchArgs {
  const PlayerLaunchArgs({
    this.coverImageAsset,
    this.displayTitle,
    this.displaySubtitle,
  });

  final String? coverImageAsset;
  final String? displayTitle;
  final String? displaySubtitle;
}
