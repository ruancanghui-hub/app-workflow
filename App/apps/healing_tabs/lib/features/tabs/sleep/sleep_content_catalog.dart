import '../../../domain/models/sleep_content.dart';
import 'sleep_cover_art.dart';

/// 睡眠节目分类与标题库，来源：`docs/睡眠的标题.md` 第二节「节目卡片标题」。
abstract final class SleepContentCatalog {
  static const _sounds = ['valley_rain', 'ocean_waves', 'pine_forest'];

  static String _soundAt(int index) => _sounds[index % _sounds.length];

  static final featured = <SleepFeaturedItem>[
    SleepFeaturedItem(
      title: '月光入梦',
      subtitle: '湖畔月夜 · 睡前冥想',
      soundId: 'valley_rain',
      coverImageAsset: SleepCoverArt.pool[0],
    ),
    SleepFeaturedItem(
      title: '星野漫游',
      subtitle: '睡眠故事 · 星空旅途',
      soundId: 'ocean_waves',
      coverImageAsset: SleepCoverArt.pool[2],
    ),
    SleepFeaturedItem(
      title: '潮汐漫岸',
      subtitle: '自然白噪音 · 海浪声',
      soundId: 'pine_forest',
      coverImageAsset: SleepCoverArt.pool[1],
    ),
    SleepFeaturedItem(
      title: '山间云海',
      subtitle: '舒眠纯音乐 · 氛围松弛',
      soundId: 'valley_rain',
      coverImageAsset: SleepCoverArt.pool[4],
    ),
  ];

  static final categories = _buildCategories();

  static List<SleepContentCategory> _buildCategories() {
    var cover = 0;
    SleepContentItem item({
      required String title,
      required String subtitle,
      required SleepContentKind kind,
      String? soundId,
      int practiceMinutes = 10,
    }) =>
        SleepContentItem(
          title: title,
          subtitle: subtitle,
          kind: kind,
          soundId: soundId,
          practiceMinutes: practiceMinutes,
          coverImageAsset: SleepCoverArt.at(cover++),
        );

    return [
      SleepContentCategory(
        id: 'quick_fall_asleep',
        title: '快速入睡',
        hint: '躺床上睡不着',
        items: [
          item(
            title: '思绪停机',
            subtitle: '停止大脑疯狂乱想',
            kind: SleepContentKind.quickFallAsleep,
          ),
          item(
            title: '5分钟接引睡意',
            subtitle: '快速摆脱清醒',
            kind: SleepContentKind.quickFallAsleep,
            practiceMinutes: 5,
          ),
          item(
            title: '身体沉降',
            subtitle: '感受身体慢慢沉向床榻',
            kind: SleepContentKind.quickFallAsleep,
          ),
          item(
            title: '放下千头万绪',
            subtitle: '睡前清空大脑',
            kind: SleepContentKind.quickFallAsleep,
          ),
          item(
            title: '呼吸锚点',
            subtitle: '跟随呼吸慢慢入眠',
            kind: SleepContentKind.quickFallAsleep,
          ),
          item(
            title: '即刻睡意',
            subtitle: '躺床即可练习',
            kind: SleepContentKind.quickFallAsleep,
          ),
        ],
      ),
      SleepContentCategory(
        id: 'night_reentry',
        title: '半夜易醒 · 再次入睡',
        hint: '惊醒之后重回深眠',
        items: [
          item(
            title: '午夜安宁',
            subtitle: '惊醒之后重新睡去',
            kind: SleepContentKind.nightReentry,
          ),
          item(
            title: '浅眠转深睡',
            subtitle: '摆脱断断续续睡眠',
            kind: SleepContentKind.nightReentry,
          ),
          item(
            title: '驱散午夜心慌',
            subtitle: '平复夜间不安',
            kind: SleepContentKind.nightReentry,
          ),
          item(
            title: '多梦安抚',
            subtitle: '平息纷乱梦境',
            kind: SleepContentKind.nightReentry,
          ),
          item(
            title: '夜半静息',
            subtitle: '醒来不必焦虑',
            kind: SleepContentKind.nightReentry,
          ),
        ],
      ),
      SleepContentCategory(
        id: 'insomnia_anxiety',
        title: '失眠焦虑',
        hint: '害怕失眠、睡眠焦虑',
        items: [
          item(
            title: '接纳失眠',
            subtitle: '不再对抗睡不着',
            kind: SleepContentKind.insomniaAnxiety,
          ),
          item(
            title: '卸下睡眠压力',
            subtitle: '放下「必须睡着」',
            kind: SleepContentKind.insomniaAnxiety,
          ),
          item(
            title: '睡前焦虑解绑',
            subtitle: '放过紧绷的自己',
            kind: SleepContentKind.insomniaAnxiety,
          ),
          item(
            title: '与失眠温柔共处',
            subtitle: '放下对抗，温柔陪伴自己',
            kind: SleepContentKind.insomniaAnxiety,
          ),
          item(
            title: '停止内耗，安心入睡',
            subtitle: '让思绪慢慢安静下来',
            kind: SleepContentKind.insomniaAnxiety,
          ),
        ],
      ),
      SleepContentCategory(
        id: 'sleep_story',
        title: '睡眠故事',
        hint: '人声叙事，脑子静不下来',
        items: [
          item(
            title: '星野漫游',
            subtitle: '星空下的静谧旅途',
            kind: SleepContentKind.sleepStory,
            soundId: 'valley_rain',
          ),
          item(
            title: '海岛夜信',
            subtitle: '晚风里的温柔叙事',
            kind: SleepContentKind.sleepStory,
            soundId: 'ocean_waves',
          ),
          item(
            title: '山林月游记',
            subtitle: '月色下漫步山野',
            kind: SleepContentKind.sleepStory,
            soundId: 'pine_forest',
          ),
          item(
            title: '雾中森林来信',
            subtitle: '沉浸式睡前漫游',
            kind: SleepContentKind.sleepStory,
            soundId: 'valley_rain',
          ),
          item(
            title: '晚风渡口',
            subtitle: '静谧夜晚的小故事',
            kind: SleepContentKind.sleepStory,
            soundId: 'ocean_waves',
          ),
        ],
      ),
      SleepContentCategory(
        id: 'white_noise',
        title: '自然白噪音',
        hint: '环境音，无旁白',
        items: [
          item(
            title: '雨夜小屋',
            subtitle: '躲在屋内听淅沥雨声',
            kind: SleepContentKind.whiteNoise,
            soundId: 'valley_rain',
          ),
          item(
            title: '潮汐漫岸',
            subtitle: '海浪一遍遍抚平心绪',
            kind: SleepContentKind.whiteNoise,
            soundId: 'ocean_waves',
          ),
          item(
            title: '林间雾境',
            subtitle: '薄雾森林的晚风',
            kind: SleepContentKind.whiteNoise,
            soundId: 'pine_forest',
          ),
          item(
            title: '篝火夜话',
            subtitle: '远处柔和柴火噼啪',
            kind: SleepContentKind.whiteNoise,
            soundId: 'valley_rain',
          ),
          item(
            title: '山涧清涧',
            subtitle: '潺潺流水伴夜色',
            kind: SleepContentKind.whiteNoise,
            soundId: 'ocean_waves',
          ),
        ],
      ),
      SleepContentCategory(
        id: 'pure_music',
        title: '舒眠纯音乐',
        hint: '纯配乐背景',
        items: [
          item(
            title: '月落时分',
            subtitle: '静谧夜晚氛围乐',
            kind: SleepContentKind.pureMusic,
            soundId: 'pine_forest',
          ),
          item(
            title: '星子浮沉',
            subtitle: '空灵舒缓旋律',
            kind: SleepContentKind.pureMusic,
            soundId: 'valley_rain',
          ),
          item(
            title: '夜色流音',
            subtitle: '朦胧松弛背景音',
            kind: SleepContentKind.pureMusic,
            soundId: 'ocean_waves',
          ),
          item(
            title: '晚风漫行',
            subtitle: '柔和夜间纯音',
            kind: SleepContentKind.pureMusic,
            soundId: 'pine_forest',
          ),
        ],
      ),
      SleepContentCategory(
        id: 'yoga_nidra',
        title: 'YogaNidra 瑜伽睡眠',
        hint: '躯体逐层放松',
        items: [
          item(
            title: '身体深度休眠',
            subtitle: 'YogaNidra 深度放松',
            kind: SleepContentKind.yogaNidra,
            practiceMinutes: 20,
          ),
          item(
            title: '全身卸力',
            subtitle: '让身体彻底松下来',
            kind: SleepContentKind.yogaNidra,
            practiceMinutes: 15,
          ),
          item(
            title: '躯体释放',
            subtitle: '从脚趾到头顶逐层放松',
            kind: SleepContentKind.yogaNidra,
            practiceMinutes: 20,
          ),
        ],
      ),
      SleepContentCategory(
        id: 'power_nap',
        title: '午休小憩',
        hint: '白天短睡充电',
        items: [
          item(
            title: '10分钟电量回血',
            subtitle: '高效午休',
            kind: SleepContentKind.powerNap,
            soundId: 'valley_rain',
            practiceMinutes: 10,
          ),
          item(
            title: '办公间隙小憩',
            subtitle: '不睡沉，只修复',
            kind: SleepContentKind.powerNap,
            soundId: 'ocean_waves',
            practiceMinutes: 15,
          ),
          item(
            title: '午后轻休养',
            subtitle: '短暂放空恢复精力',
            kind: SleepContentKind.powerNap,
            soundId: 'pine_forest',
            practiceMinutes: 20,
          ),
        ],
      ),
    ];
  }

  static List<String> get categoryTabLabels => [
        '全部',
        ...categories.map((c) => c.title),
      ];

  static int get totalItemCount =>
      categories.fold(0, (sum, c) => sum + c.items.length);

  static String soundForIndex(int globalIndex) => _soundAt(globalIndex);
}
