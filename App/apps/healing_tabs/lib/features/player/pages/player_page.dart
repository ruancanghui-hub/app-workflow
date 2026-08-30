import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_design_system.dart';
import '../player_controller.dart';

class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Obx(() => Text(controller.sound.value?.title ?? '播放器')),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: HealingDesignSystem.textLight,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        switch (controller.status.value) {
          case PlayerStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case PlayerStatus.error:
            return _ErrorState(
              message: controller.errorMessage.value ?? '播放失败',
              onRetry: () {
                final id = Get.parameters['soundId'];
                if (id != null) controller.load(id);
              },
            );
          case PlayerStatus.idle:
          case PlayerStatus.playing:
          case PlayerStatus.paused:
            final sound = controller.sound.value;
            if (sound == null) {
              return const Center(child: Text('无声景', style: TextStyle(color: Colors.white)));
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    sound.subtitle,
                    style: HealingDesignSystem.subtitle,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: sound.tags
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                  const Spacer(),
                  Text(
                    _formatElapsed(controller.elapsedSeconds.value),
                    textAlign: TextAlign.center,
                    style: HealingDesignSystem.heroDisplay.copyWith(fontSize: 36),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => controller.showResumeHint.value
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '播放已暂停，点击播放继续',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 72,
                        onPressed: controller.togglePlay,
                        tooltip: '播放或暂停',
                        icon: Icon(
                          controller.status.value == PlayerStatus.playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('倒计时', style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Slider(
                          value: controller.countdownMinutes.value.toDouble(),
                          min: 5,
                          max: 90,
                          divisions: 17,
                          label: '${controller.countdownMinutes.value} 分',
                          onChanged: (v) =>
                              controller.countdownMinutes.value = v.round(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.startSleepSession,
                    child: const Text('开始睡眠会话'),
                  ),
                ],
              ),
            );
        }
      }),
    );
  }

  String _formatElapsed(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
