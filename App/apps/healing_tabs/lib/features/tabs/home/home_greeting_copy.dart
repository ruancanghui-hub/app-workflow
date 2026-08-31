/// 首页问候与提示文案池：按时段轮换，保持新鲜感。
abstract final class HomeGreetingCopy {
  static const _morningTitles = [
    '早安',
    '晨光正好',
    '新的一天',
    '清晨好',
  ];

  static const _afternoonTitles = [
    '午后好',
    '午间小憩',
    '阳光正好',
    '下午好',
  ];

  static const _eveningTitles = [
    '晚上好',
    '夜色温柔',
    '今夜好梦',
    '晚风正好',
    '星夜将至',
  ];

  static const _nightTitles = [
    '夜深了',
    '静夜安好',
    '好梦',
    '月色正好',
  ];

  static const _soundOffHints = [
    '左右滑动切换场景，轻触画面开启声音',
    '试着滑动，找到此刻最契合的风景',
    '轻触画面，让自然声陪伴你',
    '选一景，点一下，听见宁静',
  ];

  static const _soundOnHints = [
    '轻触画面可关闭环境声',
    '环境声已开启，再点一下可静音',
    '正在播放场景音，轻触可关闭',
  ];

  static String title(DateTime now) {
    final pool = switch (now.hour) {
      >= 5 && < 11 => _morningTitles,
      >= 11 && < 17 => _afternoonTitles,
      >= 17 && < 23 => _eveningTitles,
      _ => _nightTitles,
    };
    return pool[_indexFor(now, pool.length)];
  }

  static String soundOffHint(DateTime now) =>
      _soundOffHints[_indexFor(now, _soundOffHints.length)];

  static String soundOnHint(DateTime now) =>
      _soundOnHints[_indexFor(now, _soundOnHints.length)];

  static int _indexFor(DateTime now, int length) =>
      (now.day + now.month * 31 + now.hour) % length;
}
