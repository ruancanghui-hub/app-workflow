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
    this.dark = true,
  });

  final HealingLayout layout;
  final List<SleepWeekDayBar> days;
  final String? selectedId;
  final ValueChanged<SleepWeekDayBar> onSelect;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = days.fold<int>(
      1,
      (m, d) => d.minutes > m ? d.minutes : m,
    );
    final labelColor = dark ? const Color(0xFF9AA0B9) : const Color(0xFF707070);
    final valueColor = dark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF707070);
    final emptyBar = dark ? const Color(0x33FFFFFF) : const Color(0xFFE6EBF5);
    final activeBar = dark ? const Color(0xFFB0A4FF) : const Color(0xFF6B8CF5);
    final filledBar = dark ? const Color(0xFF5B8DEF) : const Color(0xFFA8C0F5);

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
                                color: valueColor,
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
                                ? activeBar
                                : day.hasData
                                ? filledBar
                                : emptyBar,
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
                    color: labelColor,
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
    this.headerIconAsset,
    this.emptyIconAsset,
  });

  final HealingLayout layout;
  final String title;
  final List<HeartRateSample> samples;
  final String emptyHint;
  final bool dark;
  final String? headerIconAsset;
  final String? emptyIconAsset;

  @override
  Widget build(BuildContext context) {
    final titleColor = dark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = dark ? const Color(0xFF9AA0B9) : const Color(0xFF707070);
    final boxColor = dark ? const Color(0xFF141C28) : const Color(0xFFF5F5F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: layout.fontModuleTitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (headerIconAsset case final asset?)
              Image.asset(
                asset,
                width: layout.pt(64),
                height: layout.pt(64),
                fit: BoxFit.contain,
              ),
          ],
        ),
        SizedBox(height: layout.sectionTitleGap),
        ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: ColoredBox(
            color: boxColor,
            child: SizedBox(
              height: layout.pt(180),
              child: samples.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(layout.pt(16)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (emptyIconAsset case final asset?) ...[
                              Image.asset(
                                asset,
                                width: layout.pt(96),
                                height: layout.pt(96),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: layout.pt(12)),
                            ],
                            Text(
                              emptyHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: hintColor,
                                fontSize: layout.fontAssist,
                                height: 1.4,
                              ),
                            ),
                          ],
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

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    const left = 36.0;
    const right = 12.0;
    const top = 12.0;
    const bottom = 28.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    if (chart.width <= 0 || chart.height <= 0) return;

    var minBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a < b ? a : b).toDouble();
    var maxBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a > b ? a : b).toDouble();
    if (maxBpm <= minBpm) {
      minBpm = (minBpm - 5).clamp(40, 200);
      maxBpm = minBpm + 10;
    }
    final span = maxBpm - minBpm;

    final axisColor = dark ? const Color(0xFF9AA0B9) : const Color(0xFF9AA0B9);
    final gridColor = dark ? const Color(0x33FFFFFF) : const Color(0x22000000);
    final lineColor = dark ? const Color(0xFFE86B6B) : const Color(0xFFE85A7A);

    final yTicks = <double>[minBpm, (minBpm + maxBpm) / 2, maxBpm];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final bpm in yTicks) {
      final y = chart.bottom - ((bpm - minBpm) / span) * chart.height;
      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      textPainter.text = TextSpan(
        text: bpm.round().toString(),
        style: TextStyle(color: axisColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chart.left - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    Offset pointFor(int i) {
      final t = samples.length == 1 ? 0.0 : i / (samples.length - 1);
      final x = chart.left + chart.width * t;
      final y = chart.bottom -
          ((samples[i].bpm - minBpm) / span).clamp(0.0, 1.0) * chart.height;
      return Offset(x, y);
    }

    final points = <Offset>[
      for (var i = 0; i < samples.length; i++) pointFor(i),
    ];

    if (points.length >= 2) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      if (!dark) {
        final fill = Path.from(path)
          ..lineTo(points.last.dx, chart.bottom)
          ..lineTo(points.first.dx, chart.bottom)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55E85A7A), Color(0x00E85A7A)],
            ).createShader(chart),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final p in points) {
      canvas.drawCircle(p, samples.length == 1 ? 5 : 3, Paint()..color = lineColor);
      if (!dark) {
        canvas.drawCircle(p, samples.length == 1 ? 5 : 3, Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
      }
    }

    final xIndices = samples.length == 1
        ? <int>[0]
        : samples.length == 2
            ? <int>[0, 1]
            : <int>[0, samples.length ~/ 2, samples.length - 1];
    for (final i in xIndices) {
      final p = points[i];
      textPainter.text = TextSpan(
        text: _hm(samples[i].at),
        style: TextStyle(color: axisColor, fontSize: 10),
      );
      textPainter.layout();
      var dx = p.dx - textPainter.width / 2;
      dx = dx.clamp(chart.left, chart.right - textPainter.width);
      textPainter.paint(canvas, Offset(dx, chart.bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _HrLinePainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.dark != dark;
}
