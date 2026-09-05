import 'package:flutter/material.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/heart_rate_series.dart';
import '../../../domain/models/sleep_session.dart';

/// 睡眠报告「本周」时长柱图（近 7 个睡眠日）。
class SleepWeekDurationChart extends StatelessWidget {
  const SleepWeekDurationChart({
    super.key,
    required this.layout,
    required this.days,
    required this.selectedId,
    required this.onSelect,
  });

  final HealingLayout layout;
  final List<SleepWeekDayBar> days;
  final String? selectedId;
  final ValueChanged<SleepWeekDayBar> onSelect;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = days.fold<int>(
      1,
      (m, d) => d.minutes > m ? d.minutes : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: layout.pt(160),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: day.hasData ? () => onSelect(day) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.hasData)
                          Padding(
                            padding: EdgeInsets.only(bottom: layout.pt(4)),
                            child: Text(
                              _shortDuration(day.minutes),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: layout.pt(10),
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: day.hasData
                              ? (day.minutes / maxMinutes) * layout.pt(120)
                              : layout.pt(8),
                          decoration: BoxDecoration(
                            color: day.id == selectedId
                                ? const Color(0xFFB0A4FF)
                                : day.hasData
                                    ? const Color(0xFF5B8DEF)
                                    : const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(layout.pt(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (day != days.last) SizedBox(width: layout.pt(6)),
              ],
            ],
          ),
        ),
        SizedBox(height: layout.pt(8)),
        Row(
          children: [
            for (final day in days) ...[
              Expanded(
                child: Text(
                  day.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF9AA0B9),
                    fontSize: layout.fontAssist,
                  ),
                ),
              ),
              if (day != days.last) SizedBox(width: layout.pt(6)),
            ],
          ],
        ),
      ],
    );
  }

  static String _shortDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h <= 0) return '$m分';
    if (m == 0) return '$h时';
    return '$h时$m';
  }
}

class SleepWeekDayBar {
  const SleepWeekDayBar({
    required this.id,
    required this.label,
    required this.sleepDayStart,
    required this.minutes,
    this.session,
  });

  final String id;
  final String label;
  final DateTime sleepDayStart;
  final int minutes;
  final SleepSession? session;

  bool get hasData => session != null && minutes > 0;
}

/// 夜间 / 冥想心率曲线空态或占位折线区。
class HeartRateCurvePanel extends StatelessWidget {
  const HeartRateCurvePanel({
    super.key,
    required this.layout,
    required this.title,
    this.samples = const [],
    this.emptyHint = '暂无心率时序。连接戒指同步后将在此展示真实曲线。',
    this.dark = true,
  });

  final HealingLayout layout;
  final String title;
  final List<HeartRateSample> samples;
  final String emptyHint;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final titleColor = dark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor =
        dark ? const Color(0xFF9AA0B9) : const Color(0xFF707070);
    final boxColor =
        dark ? const Color(0xFF141C28) : const Color(0xFFF5F5F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: layout.fontModuleTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: layout.sectionTitleGap),
        ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: ColoredBox(
            color: boxColor,
            child: SizedBox(
              height: layout.pt(160),
              child: samples.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(layout.pt(16)),
                      child: Center(
                        child: Text(
                          emptyHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: hintColor,
                            fontSize: layout.fontAssist,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _HrLinePainter(samples: samples, dark: dark),
                      child: const SizedBox.expand(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HrLinePainter extends CustomPainter {
  _HrLinePainter({required this.samples, required this.dark});

  final List<HeartRateSample> samples;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    final minBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a < b ? a : b).toDouble();
    final maxBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a > b ? a : b).toDouble();
    final span = (maxBpm - minBpm).clamp(1, 200);
    final paint = Paint()
      ..color = dark ? const Color(0xFFE86B6B) : const Color(0xFFD94A4A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * (i / (samples.length - 1));
      final y = size.height *
          (1 - ((samples[i].bpm - minBpm) / span).clamp(0.05, 0.95));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HrLinePainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.dark != dark;
}
