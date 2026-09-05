import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/design/healing_layout.dart';
import '../player_controller.dart';

class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final sound = controller.sound.value;
        final status = controller.status.value;
        // 显式订阅：定时、进度、收藏，保证设置时长与收藏态即时刷新。
        controller.countdownMinutes.value;
        controller.elapsedSeconds.value;
        controller.isFavorite.value;
        if (sound == null && status == PlayerStatus.error) {
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
          bootstrapping: controller.isBootstrapping.value,
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
    required this.bootstrapping,
    this.coverImageAsset,
  });

  final PlayerController controller;
  final String title;
  final String subtitle;
  final String? coverImageAsset;
  final bool bootstrapping;

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
        final chromeSize = layout.pt(48);
        final chromeIcon = layout.pt(26);
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
              left: layout.pagePad,
              top: topInset + layout.pt(8),
              child: _HugeIconButton(
                icon: HugeIcons.strokeRoundedCancel01,
                size: chromeSize,
                iconSize: chromeIcon,
                tooltip: '关闭播放器',
                onPressed: Get.back,
              ),
            ),
            Positioned(
              left: layout.pagePad,
              right: layout.pagePad,
              top: topInset + layout.pt(56),
              bottom: bottomInset + layout.pt(16),
              child: Column(
                children: [
                  const Spacer(),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: layout.pt(340)),
                    child: _PlayerCard(
                      layout: layout,
                      title: title,
                      subtitle: subtitle,
                      controller: controller,
                    ),
                  ),
                  SizedBox(height: layout.pt(12)),
                  SizedBox(
                    height: layout.pt(48),
                    child: _TrialBanner(layout: layout),
                  ),
                  SizedBox(height: layout.pt(8)),
                  Text(
                    '随时取消 · 无需付费',
                    style: TextStyle(
                      color: const Color(0xD9F5E5D0),
                      fontSize: layout.pt(12),
                    ),
                  ),
                ],
              ),
            ),
            if (bootstrapping)
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
    required this.controller,
  });

  final HealingLayout layout;
  final String title;
  final String subtitle;
  final PlayerController controller;

  static const _iconColor = Color(0xFFFDF1DA);
  static const _favoriteRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.status.value == PlayerStatus.playing;
    final favorited = controller.isFavorite.value;
    final totalSeconds = math.max(controller.sessionTotalSeconds, 1);
    final progress = controller.sessionProgress;
    final sideSize = layout.pt(40);
    final sideIcon = layout.pt(28);
    final cornerSize = layout.pt(40);
    final cornerIcon = layout.pt(24);
    final playSize = layout.pt(68);
    final playIcon = layout.pt(30);

    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.pt(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x665B452B),
            border: Border.all(color: const Color(0x66FFF4E3)),
            borderRadius: BorderRadius.circular(layout.pt(16)),
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
                  layout.pt(16),
                  layout.pt(14),
                  layout.pt(16),
                  layout.pt(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/player/status/premium_plus.png',
                      width: layout.pt(48),
                      height: layout.pt(24),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: layout.pt(10)),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.pt(22),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: layout.pt(4)),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xDDF3E3CE),
                        fontSize: layout.pt(13),
                      ),
                    ),
                    SizedBox(height: layout.pt(10)),
                    SizedBox(
                      height: layout.pt(28),
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WaveformPainter(progress: progress),
                      ),
                    ),
                    SizedBox(height: layout.pt(6)),
                    Text(
                      '循环白噪音 · ${controller.countdownMinutes.value} 分钟会话',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xDBF7E8D4),
                        fontSize: layout.pt(12),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        activeTrackColor: const Color(0xFFFDF1DA),
                        inactiveTrackColor: const Color(0x55FAE9CC),
                        thumbColor: const Color(0xFFFDF1DA),
                        overlayColor: const Color(0x33FFF4E3),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (v) => controller.seekSessionFraction(v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    SizedBox(height: layout.pt(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HugeIconButton(
                          icon: HugeIcons.strokeRoundedSettings01,
                          size: cornerSize,
                          iconSize: cornerIcon,
                          tooltip: '播放设置',
                          onPressed: () =>
                              _showSettingsSheet(context, controller),
                        ),
                        _HugeIconButton(
                          icon: HugeIcons.strokeRoundedGoBackward15Sec,
                          size: sideSize,
                          iconSize: sideIcon,
                          tooltip: '后退 15 秒',
                          onPressed: () => controller.seekBySeconds(-15),
                        ),
                        _PlayButton(
                          size: playSize,
                          iconSize: playIcon,
                          isPlaying: isPlaying,
                          onPressed: controller.togglePlay,
                        ),
                        _HugeIconButton(
                          icon: HugeIcons.strokeRoundedGoForward15Sec,
                          size: sideSize,
                          iconSize: sideIcon,
                          tooltip: '前进 15 秒',
                          onPressed: () => controller.seekBySeconds(15),
                        ),
                        _FavoriteButton(
                          size: cornerSize,
                          iconSize: cornerIcon,
                          favorited: favorited,
                          outlineColor: _iconColor,
                          filledColor: _favoriteRed,
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

void _showSettingsSheet(BuildContext context, PlayerController controller) {
  const options = [15, 25, 30, 45, 60, 90];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A2430),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Obx(() {
            final selected = controller.countdownMinutes.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '播放设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '定时时长（循环白噪音会话）',
                  style: TextStyle(color: Color(0xFF9AA0B9), fontSize: 13),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final m in options)
                      ChoiceChip(
                        label: Text('$m 分钟'),
                        selected: selected == m,
                        onSelected: (_) {
                          controller.setCountdownMinutes(m);
                          Navigator.of(ctx).pop();
                        },
                        selectedColor: const Color(0xFF9D91F2),
                        labelStyle: TextStyle(
                          color: selected == m
                              ? Colors.white
                              : const Color(0xFFFDF1DA),
                        ),
                        backgroundColor: const Color(0xFF243044),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      );
    },
  );
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
    canvas.drawCircle(Offset(glowX, midY), 8, glowPaint);
    canvas.drawCircle(
      Offset(glowX, midY),
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _TrialBanner extends StatelessWidget {
  const _TrialBanner({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(999),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE8F7ECDC),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: layout.pt(16)),
          child: Row(
            children: [
              Image.asset(
                'assets/images/player/feature_art/premium_leaf.png',
                width: layout.pt(28),
                height: layout.pt(28),
              ),
              SizedBox(width: layout.pt(10)),
              Expanded(
                child: Text(
                  '开始 7 天免费试用',
                  style: TextStyle(
                    color: const Color(0xFF483C2A),
                    fontSize: layout.pt(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF483C2A),
                size: layout.pt(22),
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
    required this.size,
    required this.iconSize,
    required this.isPlaying,
    required this.onPressed,
  });

  final double size;
  final double iconSize;
  final bool isPlaying;
  final VoidCallback onPressed;

  static const _iconColor = Color(0xFFFDF1DA);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: const BorderSide(color: Color(0xC9FFF3E0), width: 2),
        shape: const CircleBorder(),
      ),
      child: HugeIcon(
        icon: isPlaying
            ? HugeIcons.strokeRoundedPause
            : HugeIcons.strokeRoundedPlay,
        size: iconSize,
        color: _iconColor,
      ),
    ),
  );
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.size,
    required this.iconSize,
    required this.favorited,
    required this.outlineColor,
    required this.filledColor,
    required this.onPressed,
  });

  final double size;
  final double iconSize;
  final bool favorited;
  final Color outlineColor;
  final Color filledColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '收藏',
    child: SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: favorited
            ? Icon(Icons.favorite, size: iconSize, color: filledColor)
            : HugeIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                size: iconSize,
                color: outlineColor,
              ),
      ),
    ),
  );
}

class _HugeIconButton extends StatelessWidget {
  const _HugeIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.tooltip,
    this.onPressed,
  });

  final List<List<dynamic>> icon;
  final double size;
  final double iconSize;
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
        icon: HugeIcon(
          icon: icon,
          size: iconSize,
          color: const Color(0xFFFDF1DA),
        ),
      ),
    ),
  );
}

TextStyle _timeStyle(HealingLayout layout) =>
    TextStyle(color: const Color(0xFFF9EDD9), fontSize: layout.pt(12));

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
