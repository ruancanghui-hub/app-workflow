/// 播放器页面启动参数（不走 URL，避免中文路径编码错误）。
class PlayerLaunchArgs {
  const PlayerLaunchArgs({
    this.coverImageAsset,
    this.displayTitle,
    this.displaySubtitle,
    this.countdownMinutes,
    this.autoPlay = false,
  });

  final String? coverImageAsset;
  final String? displayTitle;
  final String? displaySubtitle;

  /// 会话倒计时分钟；null 则用播放器默认。
  final int? countdownMinutes;

  /// 进入页后自动开播。
  final bool autoPlay;
}
