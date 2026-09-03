import 'dart:math' as math;
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
        return _PlayerSurface(
          controller: controller,
          title: controller.displayTitle.value ?? sound?.title ?? '山径',
          subtitle:
              controller.displaySubtitle.value ??
              sound?.subtitle ??
              '曲径通幽处',
          coverImageAsset: controller.coverImageAsset.value,
          durationMinutes: sound?.durationMinutes ?? 15,
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

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.loading,
    this.coverImageAsset,
  });

  final PlayerController controller;
  final String title;
  final String subtitle;
  final String? coverImageAsset;
  final int durationMinutes;
  final bool loading;

  static const _defaultScene =
      'assets/images/player/backgrounds/background_player_scene.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        final topInset = MediaQuery.paddingOf(context).top;
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              coverImageAsset ?? _defaultScene,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(_defaultScene, fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x220E0802), Color(0x88140C03)],
                ),
              ),
            ),
            Positioned(
              left: layout.dx(48),
              top: topInset + layout.sz(18),
              child: _AssetButton(
                asset: 'assets/images/player/ui_controls/close_button.png',
                size: layout.sz(74),
                tooltip: '关闭播放器',
                onPressed: Get.back,
              ),
            ),
            Positioned(
              right: layout.dx(48),
              top: topInset + layout.sz(18),
              child: _AssetButton(
                asset: 'assets/images/player/ui_controls/more_button.png',
                size: layout.sz(74),
                tooltip: '更多选项',
              ),
            ),
            Positioned(
              left: layout.dx(68),
              right: layout.dx(68),
              top: topInset + layout.sz(110),
              bottom: bottomInset + layout.sz(28),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  SizedBox(
                    height: layout.sz(620),
                    child: _PlayerCard(
                      layout: layout,
                      title: title,
                      subtitle: subtitle,
                      durationMinutes: durationMinutes,
                      controller: controller,
                    ),
                  ),
                  SizedBox(height: layout.sz(28)),
                  SizedBox(
                    height: layout.sz(112),
                    child: _TrialBanner(layout: layout),
                  ),
                  SizedBox(height: layout.sz(18)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: const Color(0xD9F5E5D0),
                        size: layout.sz(22),
                      ),
                      SizedBox(width: layout.sz(8)),
                      Text(
                        '随时取消 · 无需付费',
                        style: TextStyle(
                          color: const Color(0xD9F5E5D0),
                          fontSize: layout.sz(22),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
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
    final totalSeconds = math.max(durationMinutes * 60, 1);
    final progress = (controller.elapsedSeconds.value / totalSeconds).clamp(
      0.0,
      1.0,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.sz(48)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: layout.sz(22), sigmaY: layout.sz(22)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x665B452B),
            border: Border.all(color: const Color(0x66FFF4E3)),
            borderRadius: BorderRadius.circular(layout.sz(48)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    'assets/images/player/backgrounds/background_player_card.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  layout.sz(48),
                  layout.sz(36),
                  layout.sz(40),
                  layout.sz(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/player/status/premium_plus.png',
                          width: layout.sz(96),
                          height: layout.sz(48),
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        _PreviewPill(layout: layout),
                      ],
                    ),
                    SizedBox(height: layout.sz(28)),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.sz(64),
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: layout.sz(12)),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xDDF3E3CE),
                        fontSize: layout.sz(28),
                      ),
                    ),
                    SizedBox(height: layout.sz(18)),
                    Container(
                      width: layout.sz(72),
                      height: layout.sz(2),
                      color: const Color(0x66FFFFFF),
                    ),
                    SizedBox(height: layout.sz(22)),
                    SizedBox(
                      height: layout.sz(48),
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WaveformPainter(progress: progress),
                      ),
                    ),
                    SizedBox(height: layout.sz(18)),
                    Text(
                      '让心随山径而行，回归内在的宁静。',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xDBF7E8D4),
                        fontSize: layout.sz(22),
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: layout.sz(28)),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: layout.sz(3),
                        activeTrackColor: const Color(0xFFFDF1DA),
                        inactiveTrackColor: const Color(0x55FAE9CC),
                        thumbColor: const Color(0xFFFDF1DA),
                        overlayColor: const Color(0x33FFF4E3),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: layout.sz(8),
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: layout.sz(16),
                        ),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (_) {},
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: layout.sz(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(controller.elapsedSeconds.value),
                            style: _timeStyle(layout),
                          ),
                          Text(
                            _formatTime(totalSeconds),
                            style: _timeStyle(layout),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AssetButton(
                          asset:
                              'assets/images/player/ui_controls/player_settings.png',
                          size: layout.sz(62),
                          tooltip: '播放设置',
                        ),
                        _AssetButton(
                          asset:
                              'assets/images/player/ui_controls/rewind_15.png',
                          size: layout.sz(70),
                          tooltip: '后退 15 秒',
                        ),
                        _PlayButton(
                          layout: layout,
                          isPlaying: isPlaying,
                          onPressed: controller.togglePlay,
                        ),
                        _AssetButton(
                          asset:
                              'assets/images/player/ui_controls/forward_15.png',
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

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final midY = size.height * 0.55;
    final amp = size.height * 0.28;
    path.moveTo(0, midY);
    for (var x = 0.0; x <= size.width; x += 2) {
      final t = x / size.width;
      final y =
          midY +
          math.sin(t * math.pi * 6) * amp * 0.35 +
          math.sin(t * math.pi * 2.4) * amp * 0.55 +
          math.sin(t * math.pi * 11) * amp * 0.18;
      path.lineTo(x, y);
    }

    final paint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);

    final glowX = size.width * progress.clamp(0.08, 0.92);
    final glowPaint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(glowX, midY), 10, glowPaint);
    canvas.drawCircle(
      Offset(glowX, midY),
      3.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: layout.sz(18),
      vertical: layout.sz(10),
    ),
    decoration: BoxDecoration(
      color: const Color(0x3DFFF6E8),
      border: Border.all(color: const Color(0x55FFF8E9)),
      borderRadius: BorderRadius.circular(layout.sz(999)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/player/ui_controls/preview_headphones.png',
          width: layout.sz(28),
          height: layout.sz(28),
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
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(layout.sz(999)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE8F7ECDC),
          borderRadius: BorderRadius.circular(layout.sz(999)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: layout.sz(36)),
          child: Row(
            children: [
              Image.asset(
                'assets/images/player/feature_art/premium_leaf.png',
                width: layout.sz(48),
                height: layout.sz(48),
              ),
              SizedBox(width: layout.sz(18)),
              Expanded(
                child: Text(
                  '开始 7 天免费试用',
                  style: TextStyle(
                    color: const Color(0xFF483C2A),
                    fontSize: layout.sz(30),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF483C2A),
                size: layout.sz(42),
              ),
            ],
          ),
        ),
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
    width: layout.sz(120),
    height: layout.sz(120),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide(
          color: const Color(0xC9FFF3E0),
          width: layout.sz(2),
        ),
        shape: const CircleBorder(),
      ),
      child: isPlaying
          ? Image.asset(
              'assets/images/player/ui_controls/pause_button.png',
              width: layout.sz(48),
              height: layout.sz(48),
            )
          : Icon(
              Icons.play_arrow_rounded,
              color: const Color(0xFFFDF1DA),
              size: layout.sz(56),
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
