/// 冥想内容封面图池（偏日间亮色场景）。
abstract final class MeditationCoverArt {
  static const pool = <String>[
    'assets/images/home/home_bg/悠静晨林.png',
    'assets/images/home/home_bg/樱花山谷.PNG',
    'assets/images/home/home_bg/宁静山路.PNG',
    'assets/images/home/home_bg/森林溪流.PNG',
    'assets/images/home/home_bg/山间云海.PNG',
    'assets/images/meditation/backgrounds/background_beginner_entry.png',
    'assets/images/meditation/backgrounds/background_stress_relief.png',
    'assets/images/meditation/backgrounds/background_emotion_regulation.png',
    'assets/images/home/home_bg/海边落日沙滩.PNG',
  ];

  static String at(int index) => pool[index % pool.length];
}
