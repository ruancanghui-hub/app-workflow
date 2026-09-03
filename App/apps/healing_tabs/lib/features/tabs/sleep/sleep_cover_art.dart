/// 睡眠内容封面图池（复用首页场景图）。
abstract final class SleepCoverArt {
  static const pool = <String>[
    'assets/images/home/home_bg/湖畔月夜.PNG',
    'assets/images/home/home_bg/海边落日沙滩.PNG',
    'assets/images/home/home_bg/樱花山谷.PNG',
    'assets/images/home/home_bg/森林溪流.PNG',
    'assets/images/home/home_bg/山间云海.PNG',
    'assets/images/home/home_bg/雪山静谧.PNG',
    'assets/images/home/home_bg/悠静晨林.png',
    'assets/images/home/home_bg/宁静山路.PNG',
  ];

  static String at(int index) => pool[index % pool.length];
}
