import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/haptics/healing_haptics.dart';
import '../../../core/design/healing_design_system.dart';
import '../../sleep_session/sleep_session_controller.dart';

class SleepSessionPage extends GetView<SleepSessionController> {
  const SleepSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('睡眠中'),
      ),
      body: Obx(() {
        final session = controller.session.value;
        if (session == null) {
          return const Center(
            child: Text('暂无进行中的会话', style: TextStyle(color: Colors.white70)),
          );
        }
        final minutes = controller.elapsed.value.inMinutes;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '已入睡 $minutes 分钟',
                style: HealingDesignSystem.heroDisplay.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                '会话仍在继续。你可以结束并保存本次记录。',
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  HealingHaptics.medium();
                  final ended = await controller.endAndSave();
                  await Get.offNamed(
                    '/sleep/report',
                    arguments: ended,
                  );
                },
                child: const Text('结束并查看报告'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
