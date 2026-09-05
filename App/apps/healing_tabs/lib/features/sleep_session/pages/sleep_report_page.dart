import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleep_stages_chart/sleep_stages_chart.dart';

import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../../domain/models/heart_rate_series.dart';
import '../../../domain/models/sleep_day.dart';
import '../../../domain/models/sleep_session.dart';
import '../../../domain/models/sleep_stage_segment.dart';
import '../../../domain/repositories/heart_rate_repository.dart';
import '../../../domain/repositories/sleep_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/device/device_content_catalog.dart';
import '../../tabs/meditation/meditation_content_catalog.dart';
import '../../tabs/sleep/sleep_content_catalog.dart';
import '../widgets/sleep_chart_panels.dart';

enum _ReportViewMode { night, week }

class SleepReportPage extends StatefulWidget {
  const SleepReportPage({super.key});

  @override
  State<SleepReportPage> createState() => _SleepReportPageState();
}

class _SleepReportPageState extends State<SleepReportPage> {
  int? _rating;
  bool _saving = false;
  _ReportViewMode _mode = _ReportViewMode.night;
  SleepSession? _session;
  List<SleepWeekDayBar> _weekBars = const [];
  List<HeartRateSample> _nightHr = const [];
  bool _bootstrapped = false;

  static const _soundLabels = {
    'valley_rain': '山谷雨声',
    'ocean_waves': '海边浪声',
    'pine_forest': '林间风声',
  };

  static const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    final arg = Get.arguments;
    if (arg is SleepSession) {
      _session = arg;
    }
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final history = await Get.find<SleepRepository>().listHistory();
    final byDay = <String, SleepSession>{};
    for (final s in history) {
      final id = SleepDay.idOf(s.startedAt);
      byDay.putIfAbsent(id, () => s);
    }
    final starts = SleepDay.recentStarts(DateTime.now(), count: 7);
    final bars = starts.map((start) {
      final id = SleepDay.idOf(start);
      final session = byDay[id];
      return SleepWeekDayBar(
        id: id,
        label: _weekdayLabels[start.weekday - 1],
        sleepDayStart: start,
        minutes: session?.duration.inMinutes ?? 0,
        session: session,
      );
    }).toList();

    List<HeartRateSample> hr = const [];
    final session = _session;
    if (session != null && Get.isRegistered<HeartRateRepository>()) {
      final series = await Get.find<HeartRateRepository>().nightSeriesForSleepDay(
        SleepDay.startOf(session.startedAt),
      );
      hr = series?.samples ?? const [];
    }

    if (!mounted) return;
    setState(() {
      _weekBars = bars;
      _nightHr = hr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: Text('无报告数据')));
    }
    final layout = HealingLayout.of(context);
    final minutes = session.duration.inMinutes;
    final isReadOnly = session.rating != null;
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    final soundLabel = session.soundId == null
        ? null
        : _soundLabels[session.soundId] ?? session.soundId;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/sleep_meditation_v1/backgrounds/sleep_player_scene.png',
            fit: BoxFit.cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xB80B1020)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(layout.pagePad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: layout.pt(12)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '睡眠报告',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: layout.fontPageTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _ModeChip(
                        layout: layout,
                        mode: _mode,
                        onChanged: (m) => setState(() => _mode = m),
                      ),
                    ],
                  ),
                  if (_mode == _ReportViewMode.week) ...[
                    SizedBox(height: layout.pt(20)),
                    Text(
                      '本周睡眠时长',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontModuleTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: layout.sectionTitleGap),
                    Text(
                      '点选有数据的一天，查看该夜阶段与心率',
                      style: TextStyle(
                        color: const Color(0xFF9AA0B9),
                        fontSize: layout.fontAssist,
                      ),
                    ),
                    SizedBox(height: layout.pt(16)),
                    SleepWeekDurationChart(
                      layout: layout,
                      days: _weekBars,
                      selectedId: SleepDay.idOf(session.startedAt),
                      onSelect: (bar) {
                        if (bar.session == null) return;
                        setState(() {
                          _session = bar.session;
                          _mode = _ReportViewMode.night;
                          _rating = null;
                        });
                        _loadExtras();
                      },
                    ),
                    if (_weekBars.every((b) => !b.hasData)) ...[
                      SizedBox(height: layout.pt(16)),
                      Text(
                        '近 7 个睡眠日暂无本地监测记录。完成睡眠监测后将出现在此。',
                        style: TextStyle(
                          color: const Color(0xFF9AA0B9),
                          fontSize: layout.fontAssist,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ] else ...[
                    SizedBox(height: layout.pt(6)),
                    if (session.qualityLabel != null)
                      Text(
                        session.qualityLabel!,
                        style: TextStyle(
                          color: const Color(0xFFB0A4FF),
                          fontSize: layout.fontSecondaryTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: layout.pt(20)),
                    Text(
                      '${hours > 0 ? '$hours小时' : ''}$remaining分',
                      style: HealingDesignSystem.heroDisplay.copyWith(
                        fontSize: layout.pt(44),
                      ),
                    ),
                    if (session.score != null) ...[
                      SizedBox(height: layout.pt(6)),
                      Text(
                        '睡眠分数 ${session.score}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: layout.fontCardTitle,
                        ),
                      ),
                    ],
                    if (session.insight != null) ...[
                      SizedBox(height: layout.pt(10)),
                      Text(
                        session.insight!,
                        style: TextStyle(
                          color: const Color(0xFF9AA0B9),
                          fontSize: layout.fontAssist,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (soundLabel != null) ...[
                      SizedBox(height: layout.pt(8)),
                      Text(
                        '伴睡声景：$soundLabel',
                        style: TextStyle(
                          color: const Color(0xFF9AA0B9),
                          fontSize: layout.fontAssist,
                        ),
                      ),
                    ],
                    SizedBox(height: layout.moduleSpace),
                    if (session.stages != null && session.stages!.isNotEmpty) ...[
                      Text(
                        '睡眠阶段',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: layout.fontModuleTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: layout.sectionTitleGap),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(layout.radiusContent),
                        child: ColoredBox(
                          color: const Color(0xFF141C28),
                          child: Padding(
                            padding: EdgeInsets.all(layout.pt(8)),
                            child: SleepStagesChart(
                              day: session.startedAt,
                              segments: _toChartSegments(session.stages!),
                              height: layout.pt(200),
                              style: const SleepStagesStyle(
                                stageColors: {
                                  SleepStage.deep: Color(0xFF2E7D6F),
                                  SleepStage.light: Color(0xFF5B9E8A),
                                  SleepStage.rem: Color(0xFF5B8DEF),
                                  SleepStage.awake: Color(0xFFE6A23C),
                                },
                                labelTextStyle: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB8C4D6),
                                ),
                              ),
                              labeler: (stage) => switch (stage) {
                                SleepStage.deep => '深睡',
                                SleepStage.light => '浅睡',
                                SleepStage.rem => 'REM',
                                SleepStage.awake => '清醒',
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: layout.moduleSpace),
                    ],
                    HeartRateCurvePanel(
                      layout: layout,
                      title: '夜间心率',
                      samples: _nightHr,
                    ),
                    SizedBox(height: layout.moduleSpace),
                    Text(
                      isReadOnly ? '历史评分' : '睡得怎么样？（可选）',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontCardTitle,
                      ),
                    ),
                    SizedBox(height: layout.pt(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 1; i <= 5; i++)
                          IconButton(
                            onPressed: isReadOnly || _saving
                                ? null
                                : () => setState(() => _rating = i),
                            icon: Icon(
                              i <= (_rating ?? session.rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFB0A4FF),
                              size: layout.pt(28),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: layout.moduleSpace),
                    Text(
                      '根据体征推荐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontModuleTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: layout.sectionTitleGap),
                    _RecommendTile(
                      layout: layout,
                      title: DeviceContentCatalog.recommendations.first.title,
                      subtitle:
                          DeviceContentCatalog.recommendations.first.subtitle,
                      onTap: () => openSleepContent(
                        SleepContentCatalog.categories.first.items.first,
                      ),
                    ),
                    SizedBox(height: layout.cardGap),
                    _RecommendTile(
                      layout: layout,
                      title: DeviceContentCatalog.recommendations[1].title,
                      subtitle:
                          DeviceContentCatalog.recommendations[1].subtitle,
                      onTap: () => openMeditationContent(
                        MeditationContentCatalog.categories.first.items.first,
                      ),
                    ),
                    SizedBox(height: layout.moduleSpace),
                    FilledButton(
                      onPressed: isReadOnly
                          ? () {
                              openDeviceTab();
                              Get.back();
                            }
                          : _saving
                              ? null
                              : () async {
                                  setState(() => _saving = true);
                                  try {
                                    if (_rating != null) {
                                      await Get.find<SleepRepository>()
                                          .saveRating(
                                        session.id,
                                        _rating!,
                                      );
                                    }
                                    if (!mounted) return;
                                    openDeviceTab();
                                    Get.back();
                                  } finally {
                                    if (mounted) {
                                      setState(() => _saving = false);
                                    }
                                  }
                                },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9D91F2),
                        minimumSize: Size.fromHeight(layout.pt(52)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      child: Text(
                        _saving ? '保存中…' : '完成，回戒指 Tab',
                        style: TextStyle(fontSize: layout.fontButton),
                      ),
                    ),
                  ],
                  SizedBox(height: layout.pt(16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SleepSegment> _toChartSegments(List<SleepStageSegment> stages) {
    return stages
        .map(
          (s) => SleepSegment(
            start: s.start,
            end: s.end,
            stage: switch (s.kind) {
              SleepStageKind.deep => SleepStage.deep,
              SleepStageKind.light => SleepStage.light,
              SleepStageKind.rem => SleepStage.rem,
              SleepStageKind.awake => SleepStage.awake,
            },
          ),
        )
        .toList();
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.layout,
    required this.mode,
    required this.onChanged,
  });

  final HealingLayout layout;
  final _ReportViewMode mode;
  final ValueChanged<_ReportViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(layout.pt(3)),
      decoration: BoxDecoration(
        color: const Color(0x331A2430),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip('一夜', _ReportViewMode.night),
          _chip('本周', _ReportViewMode.week),
        ],
      ),
    );
  }

  Widget _chip(String label, _ReportViewMode value) {
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: layout.pt(12),
          vertical: layout.pt(6),
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF9D91F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: layout.fontAssist,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _RecommendTile extends StatelessWidget {
  const _RecommendTile({
    required this.layout,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final HealingLayout layout;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x331A2430),
      borderRadius: BorderRadius.circular(layout.radiusDepart),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(layout.radiusDepart),
        child: Padding(
          padding: EdgeInsets.all(layout.pt(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontCardTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: layout.pt(4)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF9AA0B9),
                        fontSize: layout.fontAssist,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF9AA0B9),
                size: layout.pt(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
