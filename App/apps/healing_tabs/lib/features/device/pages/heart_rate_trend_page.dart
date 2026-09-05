import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/heart_rate_series.dart';
import '../../../domain/repositories/heart_rate_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../sleep_session/widgets/sleep_chart_panels.dart';

/// 独立心率趋势页：上段睡眠相关大卡，下段近 7 天冥想练习列表。
abstract final class _HrTone {
  static const bg = Color(0xFFF5F8FC);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const muted = Color(0xFF707070);
  static const accent = Color(0xFFE85A7A);
}

class HeartRateTrendPage extends StatefulWidget {
  const HeartRateTrendPage({super.key});

  @override
  State<HeartRateTrendPage> createState() => _HeartRateTrendPageState();
}

class _HeartRateTrendPageState extends State<HeartRateTrendPage>
    with WidgetsBindingObserver {
  List<NightHeartRateSeries> _nights = const [];
  List<MeditationHeartRateRecord> _meditations = const [];
  MeditationHeartRateRecord? _selectedMeditation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = Get.find<HeartRateRepository>();
    final nights = await repo.recentNightSeries(days: 7);
    final meds = await repo.recentMeditationRecords(days: 7);
    if (!mounted) return;
    setState(() {
      _nights = nights;
      _meditations = meds;
      final selectedId = _selectedMeditation?.id;
      if (selectedId != null) {
        MeditationHeartRateRecord? match;
        for (final m in meds) {
          if (m.id == selectedId) {
            match = m;
            break;
          }
        }
        _selectedMeditation = match;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = HealingLayout.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: _HrTone.bg,
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
                    color: _HrTone.ink,
                  ),
                  Expanded(
                    child: Text(
                      '心率',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _HrTone.ink,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _load,
                    icon: Icon(Icons.refresh, size: layout.pt(20)),
                    color: _HrTone.muted,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        layout.pagePad,
                        layout.pt(8),
                        layout.pagePad,
                        layout.pt(32),
                      ),
                      children: [
                        Text(
                          '近 7 天 · 有真时序才展示曲线',
                          style: TextStyle(
                            color: _HrTone.muted,
                            fontSize: layout.fontIntro,
                          ),
                        ),
                        SizedBox(height: layout.moduleSpace),
                        Text(
                          '睡眠相关',
                          style: TextStyle(
                            color: _HrTone.ink,
                            fontSize: layout.fontModuleTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: layout.sectionTitleGap),
                        if (_nights.isEmpty)
                          _EmptyBlock(
                            layout: layout,
                            text:
                                '近 7 个睡眠日暂无夜间心率时序。戒指同步后将显示在此；也可从睡眠报告查看该夜曲线。',
                            actionLabel: '查看睡眠报告',
                            onAction: openRingSleepReport,
                          )
                        else
                          _HeroHrCard(
                            layout: layout,
                            series: _nights.first,
                          ),
                        SizedBox(height: layout.moduleSpace),
                        Text(
                          '冥想相关',
                          style: TextStyle(
                            color: _HrTone.ink,
                            fontSize: layout.fontModuleTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: layout.sectionTitleGap),
                        if (_meditations.isEmpty)
                          _EmptyBlock(
                            layout: layout,
                            text:
                                '近 7 天暂无冥想心率记录。请先连接戒指，播放冥想内容并暂停/结束后才会写入；也可下拉或点右上角刷新。',
                          )
                        else ...[
                          for (final m in _meditations)
                            Padding(
                              padding: EdgeInsets.only(bottom: layout.cardGap),
                              child: Material(
                                color: _HrTone.card,
                                borderRadius: BorderRadius.circular(
                                  layout.radiusContent,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    layout.radiusContent,
                                  ),
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
                                                  color: _HrTone.ink,
                                                  fontSize:
                                                      layout.fontCardTitle,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: layout.pt(4)),
                                              Text(
                                                '${_fmt(m.startedAt)} · ${m.duration.inMinutes} 分钟 · ${m.samples.length} 点',
                                                style: TextStyle(
                                                  color: _HrTone.muted,
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
                                          color: _HrTone.muted,
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
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _HeroHrCard extends StatelessWidget {
  const _HeroHrCard({required this.layout, required this.series});

  final HealingLayout layout;
  final NightHeartRateSeries series;

  @override
  Widget build(BuildContext context) {
    final samples = series.samples;
    final d = series.sleepDayStart;
    int? minBpm;
    int? maxBpm;
    int? latest;
    if (samples.isNotEmpty) {
      minBpm = samples.map((s) => s.bpm).reduce((a, b) => a < b ? a : b);
      maxBpm = samples.map((s) => s.bpm).reduce((a, b) => a > b ? a : b);
      latest = samples.last.bpm;
    }

    return Container(
      padding: EdgeInsets.all(layout.pt(16)),
      decoration: BoxDecoration(
        color: _HrTone.card,
        borderRadius: BorderRadius.circular(layout.radiusContent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${d.year}年${d.month}月${d.day}日',
            style: TextStyle(
              color: _HrTone.muted,
              fontSize: layout.fontAssist,
            ),
          ),
          SizedBox(height: layout.pt(12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      minBpm != null && maxBpm != null
                          ? '$minBpm-$maxBpm'
                          : '--',
                      style: TextStyle(
                        color: _HrTone.ink,
                        fontSize: layout.pt(28),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: layout.pt(4)),
                    Text(
                      '心率范围 bpm',
                      style: TextStyle(
                        color: _HrTone.muted,
                        fontSize: layout.fontAssist,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latest != null ? '$latest' : '--',
                      style: TextStyle(
                        color: _HrTone.ink,
                        fontSize: layout.pt(28),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: layout.pt(4)),
                    Text(
                      '最新 bpm',
                      style: TextStyle(
                        color: _HrTone.muted,
                        fontSize: layout.fontAssist,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: layout.pt(16)),
          HeartRateCurvePanel(
            layout: layout,
            title: '夜间心率',
            samples: samples,
            dark: false,
            emptyHint: '曲线待同步',
          ),
        ],
      ),
    );
  }
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
        color: _HrTone.card,
        borderRadius: BorderRadius.circular(layout.radiusContent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: TextStyle(
              color: _HrTone.muted,
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
                style: TextButton.styleFrom(foregroundColor: _HrTone.accent),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
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
    return HeartRateCurvePanel(
      layout: layout,
      title: record.title,
      samples: record.samples,
      dark: false,
      emptyHint: '采样点不足，无法绘制曲线',
    );
  }
}
