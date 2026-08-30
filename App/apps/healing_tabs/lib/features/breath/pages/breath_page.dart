import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_design_system.dart';
import '../breath_controller.dart';

class BreathPage extends GetView<BreathController> {
  const BreathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('呼吸练习'),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                controller.phaseLabel,
                style: HealingDesignSystem.heroDisplay.copyWith(fontSize: 36),
              ),
              const SizedBox(height: 16),
              Text(
                controller.phase.value == BreathPhase.idle ||
                        controller.phase.value == BreathPhase.done
                    ? '第 ${controller.round.value} / ${BreathController.totalRounds} 轮'
                    : '${controller.secondsLeft.value} 秒',
                style: HealingDesignSystem.subtitle,
              ),
              const Spacer(),
              if (controller.phase.value == BreathPhase.done)
                FilledButton(
                  onPressed: Get.back,
                  child: const Text('完成'),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: controller.phase.value == BreathPhase.idle
                          ? controller.start
                          : controller.pause,
                      child: Text(
                        controller.phase.value == BreathPhase.idle
                            ? '开始'
                            : '暂停',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
