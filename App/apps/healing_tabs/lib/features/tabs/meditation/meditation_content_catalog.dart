import '../../../domain/models/meditation_content.dart';
import 'meditation_cover_art.dart';

/// 冥想节目分类与标题库，来源：`docs/冥想标题.md` 第二节「节目卡片标题」。
abstract final class MeditationContentCatalog {
  static const _sounds = ['valley_rain', 'ocean_waves', 'pine_forest'];

  static String _soundAt(int index) => _sounds[index % _sounds.length];

  static final featured = <MeditationFeaturedItem>[
    MeditationFeaturedItem(
      title: '清晨温柔苏醒',
      subtitle: '日间活力 · 元气开启',
      soundId: 'pine_forest',
      coverImageAsset: MeditationCoverArt.pool[0],
    ),
    MeditationFeaturedItem(
      title: '8分钟即时泄压',
      subtitle: '快速减压 · 忙碌间隙',
      soundId: 'valley_rain',
      coverImageAsset: MeditationCoverArt.pool[6],
    ),
    MeditationFeaturedItem(
      title: '安抚焦虑',
      subtitle: '情绪急救 · 安放不安',
      soundId: 'ocean_waves',
      coverImageAsset: MeditationCoverArt.pool[7],
    ),
    MeditationFeaturedItem(
      title: '自我慈悲练习',
      subtitle: '自我成长 · 温柔善待',
      soundId: 'pine_forest',
      coverImageAsset: MeditationCoverArt.pool[1],
    ),
  ];

  static final categories = _buildCategories();

  static List<MeditationContentCategory> _buildCategories() {
    var cover = 0;
    MeditationContentItem item({
      required String title,
      required String subtitle,
      required MeditationContentKind kind,
      String? soundId,
      int practiceMinutes = 10,
    }) =>
        MeditationContentItem(
          title: title,
          subtitle: subtitle,
          kind: kind,
          soundId: soundId,
          practiceMinutes: practiceMinutes,
          coverImageAsset: MeditationCoverArt.at(cover++),
        );

    return [
      MeditationContentCategory(
        id: 'quick_relief',
        title: '快速减压',
        hint: '当下紧绷，即时松绑',
        items: [
          item(
            title: '思绪紧急暂停',
            subtitle: '摆脱杂念缠绕',
            kind: MeditationContentKind.quickRelief,
          ),
          item(
            title: '瞬间松绑',
            subtitle: '释放身体紧绷感',
            kind: MeditationContentKind.quickRelief,
          ),
          item(
            title: '8分钟即时泄压',
            subtitle: '忙碌间隙回血',
            kind: MeditationContentKind.quickRelief,
            practiceMinutes: 8,
          ),
          item(
            title: '回归内在锚点',
            subtitle: '把注意力拉回自己',
            kind: MeditationContentKind.quickRelief,
          ),
          item(
            title: '全身松驰扫描',
            subtitle: '卸下浑身压力',
            kind: MeditationContentKind.quickRelief,
            practiceMinutes: 12,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'emotion_first_aid',
        title: '情绪急救',
        hint: '焦虑烦躁难过时',
        items: [
          item(
            title: '情绪失控急救',
            subtitle: '稳住动荡心绪',
            kind: MeditationContentKind.emotionFirstAid,
          ),
          item(
            title: '安抚焦虑',
            subtitle: '安放心里的不安',
            kind: MeditationContentKind.emotionFirstAid,
          ),
          item(
            title: '怒火消散',
            subtitle: '平复冲动情绪',
            kind: MeditationContentKind.emotionFirstAid,
          ),
          item(
            title: '与坏情绪共处',
            subtitle: '接纳悲伤与委屈',
            kind: MeditationContentKind.emotionFirstAid,
          ),
          item(
            title: '停止精神内耗',
            subtitle: '放过纠结的自己',
            kind: MeditationContentKind.emotionFirstAid,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'self_growth',
        title: '自我成长',
        hint: '内心觉察与自洽',
        items: [
          item(
            title: '自我慈悲练习',
            subtitle: '温柔善待自己',
            kind: MeditationContentKind.selfGrowth,
          ),
          item(
            title: '发掘内在力量',
            subtitle: '收获笃定安全感',
            kind: MeditationContentKind.selfGrowth,
          ),
          item(
            title: '放下执念',
            subtitle: '解开心里的枷锁',
            kind: MeditationContentKind.selfGrowth,
          ),
          item(
            title: '向内看见',
            subtitle: '觉察真实的内心',
            kind: MeditationContentKind.selfGrowth,
          ),
          item(
            title: '重建内心秩序',
            subtitle: '告别混乱浮躁',
            kind: MeditationContentKind.selfGrowth,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'workplace',
        title: '职场喘息',
        hint: '上班族专属',
        items: [
          item(
            title: '工作模式断开',
            subtitle: '下班切换生活状态',
            kind: MeditationContentKind.workplace,
          ),
          item(
            title: '职场情绪缓冲',
            subtitle: '消解工作委屈烦躁',
            kind: MeditationContentKind.workplace,
          ),
          item(
            title: '会议间隙放空',
            subtitle: '高压短暂喘息',
            kind: MeditationContentKind.workplace,
            practiceMinutes: 5,
          ),
          item(
            title: '卸下职场重担',
            subtitle: '抛开工作焦虑',
            kind: MeditationContentKind.workplace,
          ),
          item(
            title: '对抗职场倦怠',
            subtitle: '找回工作节奏',
            kind: MeditationContentKind.workplace,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'study_focus',
        title: '备考静心',
        hint: '学习备考专用',
        items: [
          item(
            title: '收拢涣散注意力',
            subtitle: '进入专注状态',
            kind: MeditationContentKind.studyFocus,
          ),
          item(
            title: '考前静心',
            subtitle: '缓解考试紧张心慌',
            kind: MeditationContentKind.studyFocus,
          ),
          item(
            title: '学不进去时',
            subtitle: '平复内心浮躁',
            kind: MeditationContentKind.studyFocus,
          ),
          item(
            title: '大脑过载休整',
            subtitle: '用脑过度快速恢复',
            kind: MeditationContentKind.studyFocus,
          ),
          item(
            title: '专注力训练',
            subtitle: '拉长专注时长',
            kind: MeditationContentKind.studyFocus,
            practiceMinutes: 15,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'daytime_energy',
        title: '日间活力',
        hint: '晨起 / 午后回血',
        items: [
          item(
            title: '清晨温柔苏醒',
            subtitle: '元气开启新一天',
            kind: MeditationContentKind.daytimeEnergy,
            soundId: 'pine_forest',
          ),
          item(
            title: '驱散午后昏沉',
            subtitle: '告别萎靡犯困',
            kind: MeditationContentKind.daytimeEnergy,
            soundId: 'valley_rain',
          ),
          item(
            title: '能量呼吸唤醒',
            subtitle: '快速提振精神',
            kind: MeditationContentKind.daytimeEnergy,
            practiceMinutes: 5,
          ),
          item(
            title: '醒后解乏',
            subtitle: '摆脱睡醒慵懒无力',
            kind: MeditationContentKind.daytimeEnergy,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'social_repair',
        title: '社交修复',
        hint: '消耗过后补足能量',
        items: [
          item(
            title: '社交耗竭修复',
            subtitle: '社交之后补回能量',
            kind: MeditationContentKind.socialRepair,
          ),
          item(
            title: '放下人际烦闷',
            subtitle: '化解关系带来的烦恼',
            kind: MeditationContentKind.socialRepair,
          ),
          item(
            title: '建立内心边界',
            subtitle: '守住自己情绪空间',
            kind: MeditationContentKind.socialRepair,
          ),
        ],
      ),
      MeditationContentCategory(
        id: 'multi_day_series',
        title: '多日系列',
        hint: '循序渐进养成习惯',
        items: [
          item(
            title: '7天情绪自愈',
            subtitle: '循序渐进疗愈内心',
            kind: MeditationContentKind.multiDaySeries,
            practiceMinutes: 15,
          ),
          item(
            title: '21天正念养成',
            subtitle: '建立每日冥想习惯',
            kind: MeditationContentKind.multiDaySeries,
            practiceMinutes: 10,
          ),
          item(
            title: '7天自我接纳',
            subtitle: '拥抱不完美的自己',
            kind: MeditationContentKind.multiDaySeries,
            practiceMinutes: 12,
          ),
          item(
            title: 'CBT正念调节',
            subtitle: '重塑你的情绪模式',
            kind: MeditationContentKind.multiDaySeries,
            practiceMinutes: 15,
          ),
        ],
      ),
    ];
  }

  static String soundForIndex(int globalIndex) => _soundAt(globalIndex);
}
