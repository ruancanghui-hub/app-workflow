import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../../core/haptics/healing_haptics.dart';
import '../../../domain/models/sleep_session.dart';
import '../../navigation/app_navigation.dart';
import '../sleep_session_controller.dart';

class SleepSessionPage extends GetView<SleepSessionController> {
  const SleepSessionPage({super.key});

  static const _soundLabels = {
    'valley_rain': '山谷雨声',
    'ocean_waves': '海边浪声',
    'pine_forest': '林间风声',
  };

  @override
  Widget build(BuildContext context) {
    final layout = HealingLayout.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0E1218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Obx(
          () => Text(
            controller.isMonitoring ? '监测中' : '睡眠监测',
            style: TextStyle(fontSize: layout.fontSecondaryTitle),
          ),
        ),
      ),
      body: Obx(() {
        final session = controller.session.value;
        if (session == null) {
          return _IdleBody(layout: layout);
        }
        return _ActiveBody(layout: layout, session: session);
      }),
    );
  }
}

class _IdleBody extends GetView<SleepSessionController> {
  const _IdleBody({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(layout.pagePad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: layout.pt(24)),
          Text(
            '今晚睡眠监测',
            style: HealingDesignSystem.heroDisplay.copyWith(
              fontSize: layout.fontPageTitle * 1.1,
            ),
          ),
          SizedBox(height: layout.pt(12)),
          Text(
            '请佩戴已连接的云遥戒指，点击下方开始采集。监测过程中可选择伴睡声景。',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: layout.fontAssist,
              height: 1.45,
            ),
          ),
          Obx(() {
            final pending = controller.pendingSoundId.value;
            if (pending == null) return const SizedBox.shrink();
            final label = SleepSessionPage._soundLabels[pending] ?? pending;
            return Padding(
              padding: EdgeInsets.only(top: layout.pt(16)),
              child: Text(
                '已选伴睡：$label',
                style: TextStyle(
                  color: const Color(0xFFB0A4FF),
                  fontSize: layout.fontAssist,
                ),
              ),
            );
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => openSleepPicker(forCompanion: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB0A4FF),
              side: const BorderSide(color: Color(0x66B0A4FF)),
              minimumSize: Size.fromHeight(layout.pt(48)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            icon: Icon(Icons.nights_stay_outlined, size: layout.pt(20)),
            label: Text(
              '先选伴睡声景（可选）',
              style: TextStyle(fontSize: layout.fontButton),
            ),
          ),
          SizedBox(height: layout.cardGap),
          FilledButton(
            onPressed: () async {
              HealingHaptics.medium();
              await controller.start();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9D91F2),
              minimumSize: Size.fromHeight(layout.pt(52)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Text(
              '开始今晚监测',
              style: TextStyle(
                fontSize: layout.fontButton,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBody extends GetView<SleepSessionController> {
  const _ActiveBody({required this.layout, required this.session});
  final HealingLayout layout;
  final SleepSession session;

  @override
  Widget build(BuildContext context) {
    final minutes = controller.elapsed.value.inMinutes;
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    final durationLabel = hours > 0
        ? '$hours 小时 $remaining 分钟'
        : '$remaining 分钟';
    final soundId = session.soundId;
    final soundLabel = soundId == null
        ? '未选择伴睡声景'
        : SleepSessionPage._soundLabels[soundId] ?? soundId;

    return Padding(
      padding: EdgeInsets.all(layout.pagePad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(layout.pt(20)),
            decoration: BoxDecoration(
              color: const Color(0x331A2430),
              borderRadius: BorderRadius.circular(layout.radiusContent),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: layout.pt(10),
                      height: layout.pt(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6BEF9A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: layout.pt(8)),
                    Text(
                      '戒指监测中',
                      style: TextStyle(
                        color: const Color(0xFF6BEF9A),
                        fontSize: layout.fontAssist,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout.pt(16)),
                Text(
                  durationLabel,
                  style: HealingDesignSystem.heroDisplay.copyWith(
                    fontSize: layout.fontPageTitle * 1.35,
                  ),
                ),
                SizedBox(height: layout.pt(8)),
                Text(
                  '伴睡：$soundLabel',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: layout.fontAssist,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: layout.cardGap),
          OutlinedButton.icon(
            onPressed: () => openSleepPicker(forCompanion: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB0A4FF),
              side: const BorderSide(color: Color(0x44B0A4FF)),
              minimumSize: Size.fromHeight(layout.pt(44)),
            ),
            icon: Icon(Icons.queue_music_rounded, size: layout.pt(18)),
            label: Text(
              soundId == null ? '选择伴睡声景' : '更换伴睡声景',
              style: TextStyle(fontSize: layout.fontButton),
            ),
          ),
          const Spacer(),
          Text(
            '结束监测后将生成睡眠报告，包含睡眠阶段图与质量评分。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: layout.fontAssist,
              height: 1.4,
            ),
          ),
          SizedBox(height: layout.cardGap),
          FilledButton(
            onPressed: () async {
              HealingHaptics.medium();
              final ended = await controller.endAndSave();
              await Get.offNamed(
                '/sleep/report',
                arguments: ended,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9D91F2),
              minimumSize: Size.fromHeight(layout.pt(52)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Text(
              '结束并查看报告',
              style: TextStyle(
                fontSize: layout.fontButton,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
