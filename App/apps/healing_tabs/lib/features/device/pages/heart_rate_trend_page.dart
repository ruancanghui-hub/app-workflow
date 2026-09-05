import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/heart_rate_series.dart';
import '../../../domain/repositories/heart_rate_repository.dart';
import '../../navigation/app_navigation.dart';

/// 独立心率趋势页：上段睡眠相关，下段近 7 天冥想练习列表。
class HeartRateTrendPage extends StatefulWidget {
  const HeartRateTrendPage({super.key});

  @override
  State<HeartRateTrendPage> createState() => _HeartRateTrendPageState();
}

class _HeartRateTrendPageState extends State<HeartRateTrendPage> {
  List<NightHeartRateSeries> _nights = const [];
  List<MeditationHeartRateRecord> _meditations = const [];
  MeditationHeartRateRecord? _selectedMeditation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = Get.find<HeartRateRepository>();
    final nights = await repo.recentNightSeries(days: 7);
    final meds = await repo.recentMeditationRecords(days: 7);
    if (!mounted) return;
    setState(() {
      _nights = nights;
      _meditations = meds;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = HealingLayout.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: top),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
            child: SizedBox(
              height: layout.pt(44),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(Icons.arrow_back_ios_new, size: layout.pt(18)),
                    color: const Color(0xFF1A1A1A),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      layout.pagePad,
                      layout.pt(8),
                      layout.pagePad,
                      layout.pt(32),
                    ),
                    children: [
                      Text(
                        '心率趋势',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: layout.fontPageTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: layout.pt(6)),
                      Text(
                        '近 7 天 · 有真时序才展示曲线',
                        style: TextStyle(
                          color: const Color(0xFF707070),
                          fontSize: layout.fontIntro,
                        ),
                      ),
                      SizedBox(height: layout.moduleSpace),
                      Text(
                        '睡眠相关',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: layout.fontModuleTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: layout.sectionTitleGap),
                      if (_nights.isEmpty)
                        _EmptyBlock(
                          layout: layout,
                          text: '近 7 个睡眠日暂无夜间心率时序。戒指同步后将显示在此；也可从睡眠报告查看该夜曲线。',
                          actionLabel: '查看睡眠报告',
                          onAction: openRingSleepReport,
                        )
                      else
                        ..._nights.map(
                          (n) => Padding(
                            padding: EdgeInsets.only(bottom: layout.cardGap),
                            child: _NightTile(layout: layout, series: n),
                          ),
                        ),
                      SizedBox(height: layout.moduleSpace),
                      Text(
                        '冥想相关',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: layout.fontModuleTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: layout.sectionTitleGap),
                      if (_meditations.isEmpty)
                        _EmptyBlock(
                          layout: layout,
                          text: '近 7 天暂无冥想心率记录。佩戴戒指播放冥想内容时，采到有效采样后会出现在此列表。',
                        )
                      else ...[
                        for (final m in _meditations)
                          Padding(
                            padding: EdgeInsets.only(bottom: layout.cardGap),
                            child: Material(
                              color: const Color(0xFFF5F5F7),
                              borderRadius:
                                  BorderRadius.circular(layout.radiusContent),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(layout.radiusContent),
                                onTap: () => setState(
                                  () => _selectedMeditation =
                                      _selectedMeditation?.id == m.id
                                          ? null
                                          : m,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(layout.pt(14)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.title,
                                              style: TextStyle(
                                                color: const Color(0xFF1A1A1A),
                                                fontSize: layout.fontCardTitle,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: layout.pt(4)),
                                            Text(
                                              '${_fmt(m.startedAt)} · ${m.duration.inMinutes} 分钟 · ${m.samples.length} 点',
                                              style: TextStyle(
                                                color: const Color(0xFF707070),
                                                fontSize: layout.fontAssist,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        _selectedMeditation?.id == m.id
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: const Color(0xFF707070),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_selectedMeditation != null) ...[
                          SizedBox(height: layout.pt(8)),
                          _MeditationCurve(
                            layout: layout,
                            record: _selectedMeditation!,
                          ),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.layout,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final HealingLayout layout;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(layout.pt(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(layout.radiusContent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: layout.fontAssist,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: layout.pt(12)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NightTile extends StatelessWidget {
  const _NightTile({required this.layout, required this.series});

  final HealingLayout layout;
  final NightHeartRateSeries series;

  @override
  Widget build(BuildContext context) {
    final d = series.sleepDayStart;
    return Container(
      padding: EdgeInsets.all(layout.pt(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(layout.radiusContent),
      ),
      child: Text(
        '${d.month}/${d.day} · ${series.samples.length} 个采样',
        style: TextStyle(
          color: const Color(0xFF1A1A1A),
          fontSize: layout.fontCardTitle,
        ),
      ),
    );
  }
}

class _MeditationCurve extends StatelessWidget {
  const _MeditationCurve({required this.layout, required this.record});

  final HealingLayout layout;
  final MeditationHeartRateRecord record;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.radiusContent),
      child: ColoredBox(
        color: const Color(0xFFF5F5F7),
        child: SizedBox(
          height: layout.pt(140),
          child: record.samples.length < 2
              ? Center(
                  child: Text(
                    '采样点不足，无法绘制曲线',
                    style: TextStyle(
                      color: const Color(0xFF707070),
                      fontSize: layout.fontAssist,
                    ),
                  ),
                )
              : CustomPaint(
                  painter: _SimpleHrPainter(record.samples),
                  child: const SizedBox.expand(),
                ),
        ),
      ),
    );
  }
}

class _SimpleHrPainter extends CustomPainter {
  _SimpleHrPainter(this.samples);

  final List<HeartRateSample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;
    final minBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a < b ? a : b).toDouble();
    final maxBpm =
        samples.map((s) => s.bpm).reduce((a, b) => a > b ? a : b).toDouble();
    final span = (maxBpm - minBpm).clamp(1, 200);
    final paint = Paint()
      ..color = const Color(0xFFD94A4A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
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
  bool shouldRepaint(covariant _SimpleHrPainter oldDelegate) =>
      oldDelegate.samples != samples;
}
