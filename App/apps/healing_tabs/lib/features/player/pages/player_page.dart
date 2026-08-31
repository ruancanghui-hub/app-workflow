import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../player_controller.dart';

class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final sound = controller.sound.value;
        if (sound == null && controller.status.value == PlayerStatus.error) {
          return _ErrorState(
            message: controller.errorMessage.value ?? '播放失败',
            onRetry: _retry,
          );
        }
        return _SleepV1Player(
          controller: controller,
          title: sound?.title ?? '山谷雨声',
          loading: controller.status.value == PlayerStatus.loading,
        );
      }),
    );
  }

  void _retry() {
    final id = Get.parameters['soundId'];
    if (id != null) controller.load(id);
  }
}

class _SleepV1Player extends StatelessWidget {
  const _SleepV1Player({
    required this.controller,
    required this.title,
    required this.loading,
  });

  final PlayerController controller;
  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/sleep_meditation_v1/backgrounds/sleep_player_scene.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66101422), Color(0xC80A101A)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.toggleFavorite,
                      icon: const Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88B0A4FF),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton.filled(
                    onPressed: controller.togglePlay,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xE6B0A4FF),
                      foregroundColor: const Color(0xFF202335),
                      fixedSize: const Size(120, 120),
                    ),
                    icon: Icon(
                      controller.status.value == PlayerStatus.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 240,
                  child: Divider(color: Color(0x99B0A4FF), thickness: 2),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x8A161C24),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '睡眠定时器',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [15, 30, 45, 60]
                                  .map(
                                    (minutes) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        child: ChoiceChip(
                                          label: Text('$minutes分'),
                                          selected:
                                              controller
                                                  .countdownMinutes
                                                  .value ==
                                              minutes,
                                          selectedColor: const Color(
                                            0xFFB0A4FF,
                                          ),
                                          labelStyle: TextStyle(
                                            color:
                                                controller
                                                        .countdownMinutes
                                                        .value ==
                                                    minutes
                                                ? const Color(0xFF202335)
                                                : Colors.white,
                                          ),
                                          onSelected: (_) =>
                                              controller
                                                      .countdownMinutes
                                                      .value =
                                                  minutes,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: loading
                                    ? null
                                    : controller.startSleepSession,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF9D91F2),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(52),
                                ),
                                child: const Text('开始睡觉'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (loading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFB0A4FF)),
          ),
      ],
    ),
  );
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.loading,
  });

  final PlayerController controller;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/player/backgrounds/background_player_scene.png',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x160E0802), Color(0x66140C03)],
                ),
              ),
            ),
            Positioned(
              left: layout.dx(58),
              top: MediaQuery.paddingOf(context).top + layout.dy(52),
              child: _AssetButton(
                asset: 'assets/images/player/ui_controls/close_button.png',
                size: layout.sz(74),
                tooltip: '关闭播放器',
                onPressed: Get.back,
              ),
            ),
            Positioned(
              right: layout.dx(58),
              top: MediaQuery.paddingOf(context).top + layout.dy(52),
              child: _AssetButton(
                asset: 'assets/images/player/ui_controls/more_button.png',
                size: layout.sz(74),
                tooltip: '更多选项',
              ),
            ),
            Positioned(
              left: layout.dx(78),
              top: layout.dy(776),
              width: layout.sz(785),
              height: layout.sz(601),
              child: _PlayerCard(
                layout: layout,
                title: title,
                subtitle: subtitle,
                durationMinutes: durationMinutes,
                controller: controller,
              ),
            ),
            Positioned(
              left: layout.dx(78),
              top: layout.dy(1424),
              width: layout.sz(785),
              height: layout.sz(148),
              child: _TrialBanner(layout: layout),
            ),
            Positioned(
              top: layout.dy(1590),
              left: 0,
              right: 0,
              child: Text(
                '◎  随时取消 · 无需付费',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xD9F5E5D0),
                  fontSize: layout.sz(22),
                ),
              ),
            ),
            if (loading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFF8ECD8)),
              ),
          ],
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.layout,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.controller,
  });

  final HealingLayout layout;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.status.value == PlayerStatus.playing;
    final progress = (controller.elapsedSeconds.value / (durationMinutes * 60))
        .clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.sz(58)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: layout.sz(18), sigmaY: layout.sz(18)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x995B452B),
            border: Border.all(color: const Color(0x80FFF4E3)),
            borderRadius: BorderRadius.circular(layout.sz(58)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.45,
                  child: Image.asset(
                    'assets/images/player/backgrounds/background_player_card.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: layout.sz(62),
                top: layout.sz(42),
                width: layout.sz(120),
                height: layout.sz(70),
                child: Image.asset(
                  'assets/images/player/status/premium_plus.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: layout.sz(48),
                top: layout.sz(48),
                width: layout.sz(170),
                height: layout.sz(70),
                child: _PreviewPill(layout: layout),
              ),
              Positioned(
                left: layout.sz(62),
                top: layout.sz(130),
                right: layout.sz(50),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.sz(70),
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: layout.sz(62),
                top: layout.sz(232),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xDDF3E3CE),
                    fontSize: layout.sz(30),
                  ),
                ),
              ),
              Positioned(
                left: layout.sz(62),
                top: layout.sz(300),
                right: layout.sz(62),
                child: Text(
                  '让心随山径而行，回归内在的宁静。',
                  style: TextStyle(
                    color: const Color(0xDBF7E8D4),
                    fontSize: layout.sz(22),
                  ),
                ),
              ),
              Positioned(
                left: layout.sz(62),
                right: layout.sz(62),
                top: layout.sz(390),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(layout.sz(4)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: layout.sz(6),
                        color: const Color(0xFFFDF1DA),
                        backgroundColor: const Color(0x66FAE9CC),
                      ),
                    ),
                    SizedBox(height: layout.sz(15)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(controller.elapsedSeconds.value),
                          style: _timeStyle(layout),
                        ),
                        Text(
                          '${durationMinutes.toString().padLeft(2, '0')}:00',
                          style: _timeStyle(layout),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: layout.sz(42),
                right: layout.sz(42),
                bottom: layout.sz(34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AssetButton(
                      asset:
                          'assets/images/player/ui_controls/player_settings.png',
                      size: layout.sz(62),
                      tooltip: '播放设置',
                    ),
                    _AssetButton(
                      asset: 'assets/images/player/ui_controls/rewind_15.png',
                      size: layout.sz(70),
                      tooltip: '后退 15 秒',
                    ),
                    _PlayButton(
                      layout: layout,
                      isPlaying: isPlaying,
                      onPressed: controller.togglePlay,
                    ),
                    _AssetButton(
                      asset: 'assets/images/player/ui_controls/forward_15.png',
                      size: layout.sz(70),
                      tooltip: '前进 15 秒',
                    ),
                    _AssetButton(
                      asset:
                          'assets/images/player/ui_controls/favorite_button.png',
                      size: layout.sz(62),
                      tooltip: '收藏',
                      onPressed: controller.toggleFavorite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0x3DFFF6E8),
      border: Border.all(color: const Color(0x55FFF8E9)),
      borderRadius: BorderRadius.circular(layout.sz(999)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/player/ui_controls/preview_headphones.png',
          width: layout.sz(34),
          height: layout.sz(34),
        ),
        SizedBox(width: layout.sz(8)),
        Text(
          '试听',
          style: TextStyle(color: Colors.white, fontSize: layout.sz(24)),
        ),
      ],
    ),
  );
}

class _TrialBanner extends StatelessWidget {
  const _TrialBanner({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xE8F7ECDC),
      borderRadius: BorderRadius.circular(layout.sz(999)),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.sz(50)),
      child: Row(
        children: [
          Image.asset(
            'assets/images/player/feature_art/premium_leaf.png',
            width: layout.sz(54),
            height: layout.sz(54),
          ),
          SizedBox(width: layout.sz(22)),
          Expanded(
            child: Text(
              '开始 7 天免费试用',
              style: TextStyle(
                color: const Color(0xFF483C2A),
                fontSize: layout.sz(31),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF483C2A),
            size: layout.sz(48),
          ),
        ],
      ),
    ),
  );
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.layout,
    required this.isPlaying,
    required this.onPressed,
  });

  final HealingLayout layout;
  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: layout.sz(136),
    height: layout.sz(136),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: const BorderSide(color: Color(0xC9FFF3E0)),
        shape: const CircleBorder(),
      ),
      child: Image.asset(
        'assets/images/player/ui_controls/pause_button.png',
        width: layout.sz(58),
        height: layout.sz(58),
      ),
    ),
  );
}

class _AssetButton extends StatelessWidget {
  const _AssetButton({
    required this.asset,
    required this.size,
    required this.tooltip,
    this.onPressed,
  });

  final String asset;
  final double size;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed ?? () {},
        icon: Image.asset(asset, fit: BoxFit.contain),
      ),
    ),
  );
}

TextStyle _timeStyle(HealingLayout layout) =>
    TextStyle(color: const Color(0xFFF9EDD9), fontSize: layout.sz(22));

String _formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
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
