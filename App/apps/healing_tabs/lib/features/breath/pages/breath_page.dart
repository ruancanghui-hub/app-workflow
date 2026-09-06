import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../breath_controller.dart';
import '../widgets/breath_control_sheets.dart';

class BreathPage extends GetView<BreathController> {
  const BreathPage({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = HealingLayout.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF071126),
      body: Obx(() {
        final phase = controller.phase.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/breath_practice/backgrounds/background_breath_practice.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x76040B1B),
                    Color(0x24040B1B),
                    Color(0xBB020817),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _BreathMotion(phase: phase, particles: true),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  layout.pagePad,
                  layout.pt(8),
                  layout.pagePad,
                  layout.pt(18),
                ),
                child: Column(
                  children: [
                    _TopBar(layout: layout),
                    SizedBox(height: layout.pt(12)),
                    Text(
                      '478呼吸',
                      style: HealingDesignSystem.heroDisplay.copyWith(
                        color: Colors.white,
                        fontSize: layout.pt(38),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: layout.pt(8)),
                    Text(
                      '放松入睡呼吸练习',
                      style: TextStyle(
                        color: const Color(0xC9D5E1FF),
                        fontSize: layout.fontSecondaryTitle,
                      ),
                    ),
                    SizedBox(height: layout.pt(20)),
                    Text(
                      '—   更慢 · 更深 · 更平静   —',
                      style: TextStyle(
                        color: const Color(0xA6D4E0F7),
                        fontSize: layout.fontAssist,
                      ),
                    ),
                    SizedBox(height: layout.pt(14)),
                    _BreathingOrb(phase: phase, layout: layout),
                    SizedBox(height: layout.pt(10)),
                    _RhythmCard(layout: layout),
                    const Spacer(),
                    _PracticeControls(phase: phase, layout: layout),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _CircleIconButton(
        icon: Icons.chevron_left_rounded,
        semanticLabel: '返回',
        layout: layout,
        onTap: Get.back,
      ),
    );
  }
}

class _BreathingOrb extends GetView<BreathController> {
  const _BreathingOrb({required this.phase, required this.layout});

  final BreathPhase phase;
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final seconds = phase == BreathPhase.idle || phase == BreathPhase.done
        ? 4
        : controller.secondsLeft.value;
    final instruction = switch (phase) {
      BreathPhase.inhale => '慢慢吸气\n让身心平静',
      BreathPhase.hold => '轻轻停留\n感受安定',
      BreathPhase.exhale => '缓缓呼气\n放下紧绷',
      BreathPhase.idle => '准备好后\n开始练习',
      BreathPhase.done => '今晚辛苦了\n慢慢回到当下',
    };

    return SizedBox(
      height: layout.pt(258),
      width: layout.pt(258),
      child: GestureDetector(
        onTap: () {
          if (phase == BreathPhase.done) {
            Get.back();
          } else if (phase == BreathPhase.idle) {
            controller.start();
          } else {
            controller.pause();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: _BreathMotion(phase: phase)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phase == BreathPhase.done ? '完成' : controller.phaseLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.pt(22),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: layout.pt(8)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$seconds',
                      style: HealingDesignSystem.heroDisplay.copyWith(
                        color: Colors.white,
                        fontSize: layout.pt(60),
                        height: 0.85,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: layout.pt(6),
                        left: layout.pt(6),
                      ),
                      child: Text(
                        '秒',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: layout.pt(18),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout.pt(10)),
                Container(
                  width: layout.pt(26),
                  height: 1,
                  color: const Color(0x99E5EEFF),
                ),
                SizedBox(height: layout.pt(10)),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xC5E2EAFF),
                    fontSize: layout.fontAssist,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmCard extends StatelessWidget {
  const _RhythmCard({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: layout.pt(16),
        horizontal: layout.pt(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0x702A375B),
        borderRadius: BorderRadius.circular(layout.pt(24)),
        border: Border.all(color: const Color(0x4DDBE7FF)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: _RhythmItem(
                  title: '吸气',
                  seconds: '4',
                  english: 'INHALE',
                  color: Color(0xFFC9DCFF),
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _RhythmItem(
                  title: '屏息',
                  seconds: '7',
                  english: 'HOLD',
                  color: Color(0xFFE4C9FF),
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _RhythmItem(
                  title: '呼气',
                  seconds: '8',
                  english: 'EXHALE',
                  color: Color(0xFFFFE2B2),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.pt(16)),
          Text(
            '—   跟随节奏缓慢呼吸   —',
            style: TextStyle(
              color: const Color(0xBFDCE6FA),
              fontSize: layout.fontAssist,
            ),
          ),
        ],
      ),
    );
  }
}

class _RhythmItem extends StatelessWidget {
  const _RhythmItem({
    required this.title,
    required this.seconds,
    required this.english,
    required this.color,
  });

  final String title;
  final String seconds;
  final String english;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: seconds,
                style: HealingDesignSystem.heroDisplay.copyWith(
                  color: color,
                  fontSize: 44,
                  height: 0.85,
                ),
              ),
              const TextSpan(
                text: ' 秒',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          english,
          style: const TextStyle(color: Color(0x889DACC9), fontSize: 11),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 76,
    child: VerticalDivider(color: Color(0x88C8D6EF), thickness: 1),
  );
}

class _PracticeControls extends GetView<BreathController> {
  const _PracticeControls({required this.phase, required this.layout});

  final BreathPhase phase;
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final isDone = phase == BreathPhase.done;
    final isIdle = phase == BreathPhase.idle;
    final isRunning = !isDone && !isIdle;
    final minutesLabel = '${controller.sessionMinutes.value} 分钟';
    final natureLabel = controller.natureSoundTitle;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledControl(
              label: natureLabel,
              icon: HugeIcons.strokeRoundedLeaf01,
              layout: layout,
              onTap: () => showBreathNatureSoundSheet(context),
            ),
            _PrimaryPauseControl(
              layout: layout,
              icon: isDone
                  ? HugeIcons.strokeRoundedTick01
                  : isRunning
                  ? HugeIcons.strokeRoundedPause
                  : HugeIcons.strokeRoundedPlay,
              semanticLabel: isDone
                  ? '完成练习'
                  : isRunning
                  ? '暂停练习'
                  : '开始练习',
              onTap: () {
                if (isDone) {
                  Get.back();
                } else if (isIdle) {
                  controller.start();
                } else {
                  controller.pause();
                }
              },
            ),
            _LabeledControl(
              label: minutesLabel,
              icon: HugeIcons.strokeRoundedTimer01,
              layout: layout,
              onTap: () => showBreathDurationSheet(context),
            ),
          ],
        ),
        SizedBox(height: layout.pt(6)),
        Text(
          isDone
              ? '练习完成'
              : isIdle
              ? '轻触开始练习'
              : '正在进行 · 剩余 ${controller.sessionRemainingLabel}',
          style: TextStyle(
            color: const Color(0xC9DFE8FF),
            fontSize: layout.fontAssist,
          ),
        ),
      ],
    );
  }
}

class _LabeledControl extends StatelessWidget {
  const _LabeledControl({
    required this.label,
    required this.icon,
    required this.layout,
    this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final HealingLayout layout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(layout.pt(12)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.pt(4)),
      child: Column(
        children: [
          _IconCircle(icon: icon, size: layout.pt(54), iconSize: layout.pt(24)),
          SizedBox(height: layout.pt(6)),
          SizedBox(
            width: layout.pt(72),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: layout.fontAssist,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final List<List<dynamic>> icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0x4D26355A),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0x66D9E5FF)),
    ),
    alignment: Alignment.center,
    child: HugeIcon(icon: icon, size: iconSize, color: Colors.white),
  );
}

class _PrimaryPauseControl extends StatelessWidget {
  const _PrimaryPauseControl({
    required this.layout,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final HealingLayout layout;
  final List<List<dynamic>> icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: layout.pt(76),
        height: layout.pt(76),
        decoration: BoxDecoration(
          color: const Color(0x70446394),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xCDE7F1FF), width: 1.4),
          boxShadow: const [
            BoxShadow(color: Color(0x883B8DFF), blurRadius: 22),
          ],
        ),
        alignment: Alignment.center,
        child: HugeIcon(
          icon: icon,
          size: layout.pt(32),
          color: Colors.white,
        ),
      ),
    ),
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.layout,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final HealingLayout layout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: semanticLabel,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: layout.pt(40),
        height: layout.pt(40),
        decoration: BoxDecoration(
          color: const Color(0x3D475A80),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x4DDEE7FF)),
        ),
        child: Icon(icon, color: Colors.white, size: layout.pt(25)),
      ),
    ),
  );
}

/// Each phase advances one turn, so the visual speed follows the 4–7–8 rhythm.
class _BreathMotion extends StatefulWidget {
  const _BreathMotion({required this.phase, this.particles = false});

  final BreathPhase phase;
  final bool particles;

  @override
  State<_BreathMotion> createState() => _BreathMotionState();
}

class _BreathMotionState extends State<_BreathMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  double _fromExpansion = 0;
  double _toExpansion = 0;
  double _turn = 0;

  double get _expansion =>
      _fromExpansion +
      (_toExpansion - _fromExpansion) *
          Curves.easeInOutSine.transform(_motion.value);

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this);
    _enterPhase();
  }

  @override
  void didUpdateWidget(covariant _BreathMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) _enterPhase();
  }

  void _enterPhase() {
    _fromExpansion = _expansion;
    _turn += _motion.value;
    _motion.stop();
    _motion.value = 0;
    _toExpansion = switch (widget.phase) {
      BreathPhase.inhale || BreathPhase.hold => 1,
      _ => 0,
    };
    final seconds = switch (widget.phase) {
      BreathPhase.inhale => 4,
      BreathPhase.hold => 7,
      BreathPhase.exhale => 8,
      _ => 1,
    };
    _motion.duration = Duration(seconds: seconds);
    _motion.forward();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, child) {
          final expansion = reducedMotion ? 0.5 : _expansion;
          final turn = reducedMotion ? 0.0 : _turn + _motion.value;
          if (widget.particles) {
            return CustomPaint(
              painter: _BreathParticles(expansion: expansion, turn: turn),
            );
          }
          return Transform.scale(
            scale: 0.80 + 0.20 * expansion,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.72 + 0.28 * expansion, child: child),
                CustomPaint(
                  painter: _OrbLight(turn: turn, expansion: expansion),
                ),
              ],
            ),
          );
        },
        child: Image.asset(
          'assets/images/breath_practice/feature_art/breathing_orb.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _OrbLight extends CustomPainter {
  const _OrbLight({required this.turn, required this.expansion});

  final double turn;
  final double expansion;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.405;
    final angle = turn * math.pi * 2 - math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final glow = Paint()
      ..color = const Color(
        0xFFBCDFFF,
      ).withValues(alpha: 0.22 + 0.18 * expansion)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawArc(rect, angle - 0.9, 1.8, false, glow);
    canvas.drawArc(
      rect,
      angle - 0.6,
      1.2,
      false,
      Paint()
        ..color = const Color(0xBBDCF3FF)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.2,
    );
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(
      point,
      3,
      Paint()
        ..color = const Color(0xFFE5F6FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_OrbLight oldDelegate) =>
      oldDelegate.turn != turn || oldDelegate.expansion != expansion;
}

class _BreathParticles extends CustomPainter {
  const _BreathParticles({required this.expansion, required this.turn});

  final double expansion;
  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.40);
    final paint = Paint();
    for (var i = 0; i < 36; i++) {
      final seed = i * 2.399963;
      final orbit = seed + turn * math.pi * 0.12;
      final distance = 0.23 + (i % 9) * 0.045;
      final spread = 0.88 + expansion * 0.16;
      final point =
          center +
          Offset(
            math.cos(orbit) * size.width * distance * spread,
            math.sin(orbit) * size.height * distance * spread,
          );
      final shimmer = 0.5 + 0.5 * math.sin(seed + turn * math.pi * 2);
      paint.color = const Color(
        0xFFD3E9FF,
      ).withValues(alpha: 0.12 + shimmer * 0.23 + expansion * 0.08);
      final radius = 0.8 + (i % 3) * 0.6;
      canvas.drawCircle(
        point,
        radius * 3,
        Paint()
          ..color = paint.color.withValues(alpha: paint.color.a * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(point, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BreathParticles oldDelegate) =>
      oldDelegate.turn != turn || oldDelegate.expansion != expansion;
}
