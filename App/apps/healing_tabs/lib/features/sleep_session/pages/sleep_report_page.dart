import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleep_stages_chart/sleep_stages_chart.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/heart_rate_series.dart';
import '../../../domain/models/sleep_content.dart';
import '../../../domain/models/sleep_day.dart';
import '../../../domain/models/sleep_session.dart';
import '../../../domain/models/sleep_stage_segment.dart';
import '../../../domain/repositories/heart_rate_repository.dart';
import '../../../domain/repositories/sleep_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/sleep/sleep_content_catalog.dart';
import '../widgets/sleep_chart_panels.dart';

enum _ReportViewMode { night, week }

/// 浅色睡眠报告：一夜优先 + 本周换皮 + 底部自然白噪音推荐。
abstract final class _ReportTone {
  static const bg = Color(0xFFF5F8FC);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const muted = Color(0xFF707070);
  static const accent = Color(0xFF6B8CF5);
}

abstract final class _ReportAssets {
  static const pageBackground =
      'assets/images/sleep_report/backgrounds/background_sleep_report.png';
  static const scoreCardBackground =
      'assets/images/sleep_report/backgrounds/background_score_card.png';
  static const moon =
      'assets/images/sleep_report/feature_art/sleep_moon_icon.png';
  static const ratingStar = 'assets/images/sleep_report/status/rating_star.png';
  static const nightHeartRate =
      'assets/images/sleep_report/status/night_heart_rate_icon.png';
  static const emptyHeartRate =
      'assets/images/sleep_report/status/heart_rate_empty_icon.png';
}

class SleepReportPage extends StatefulWidget {
  const SleepReportPage({super.key});

  @override
  State<SleepReportPage> createState() => _SleepReportPageState();
}

class _SleepReportPageState extends State<SleepReportPage> {
  int? _rating;
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

  static const _weekdayFull = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  List<SleepContentItem> get _whiteNoiseRecs {
    final match = SleepContentCatalog.categories.where(
      (c) => c.id == 'white_noise',
    );
    if (match.isEmpty) return const [];
    return match.first.items.take(5).toList();
  }

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
      final series = await Get.find<HeartRateRepository>()
          .nightSeriesForSleepDay(SleepDay.startOf(session.startedAt));
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
    final layout = HealingLayout.of(context);
    final top = MediaQuery.paddingOf(context).top;

    if (session == null) {
      return Scaffold(
        backgroundColor: _ReportTone.bg,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(layout.pagePad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  layout: layout,
                  mode: _mode,
                  onModeChanged: (m) => setState(() => _mode = m),
                  showMode: false,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '暂无睡眠数据',
                      style: TextStyle(
                        color: _ReportTone.muted,
                        fontSize: layout.fontIntro,
                      ),
                    ),
                  ),
                ),
                _TodayWhiteNoiseSection(layout: layout, items: _whiteNoiseRecs),
                SizedBox(height: layout.pt(16)),
              ],
            ),
          ),
        ),
      );
    }

    final minutes = session.duration.inMinutes;
    final isReadOnly = session.rating != null;
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    final soundLabel = session.soundId == null
        ? null
        : _soundLabels[session.soundId] ?? session.soundId;
    final day = session.startedAt;

    return Scaffold(
      backgroundColor: _ReportTone.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                _ReportAssets.pageBackground,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: top),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
                child: _TopBar(
                  layout: layout,
                  mode: _mode,
                  onModeChanged: (m) => setState(() => _mode = m),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    layout.pagePad,
                    layout.pt(8),
                    layout.pagePad,
                    layout.pt(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_mode == _ReportViewMode.week) ...[
                        _WeekBody(
                          layout: layout,
                          session: session,
                          weekBars: _weekBars,
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
                        SizedBox(height: layout.moduleSpace),
                        _TodayWhiteNoiseSection(
                          layout: layout,
                          items: _whiteNoiseRecs,
                        ),
                      ] else ...[
                        Text(
                          '${day.year}年${day.month}月${day.day}日 · ${_weekdayFull[day.weekday - 1]}',
                          style: TextStyle(
                            color: _ReportTone.muted,
                            fontSize: layout.fontAssist,
                          ),
                        ),
                        SizedBox(height: layout.pt(16)),
                        Text(
                          '夜间睡眠',
                          style: TextStyle(
                            color: _ReportTone.muted,
                            fontSize: layout.fontAssist,
                          ),
                        ),
                        SizedBox(height: layout.pt(4)),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (hours > 0) ...[
                                TextSpan(
                                  text: '$hours',
                                  style: TextStyle(
                                    color: _ReportTone.ink,
                                    fontSize: layout.pt(40),
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                                TextSpan(
                                  text: ' 小时 ',
                                  style: TextStyle(
                                    color: _ReportTone.ink,
                                    fontSize: layout.fontSecondaryTitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              TextSpan(
                                text: '$remaining',
                                style: TextStyle(
                                  color: _ReportTone.ink,
                                  fontSize: layout.pt(40),
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: ' 分钟',
                                style: TextStyle(
                                  color: _ReportTone.ink,
                                  fontSize: layout.fontSecondaryTitle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: layout.moduleSpace),
                        if (session.stages != null &&
                            session.stages!.isNotEmpty) ...[
                          _SurfaceCard(
                            layout: layout,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '睡眠阶段',
                                      style: TextStyle(
                                        color: _ReportTone.ink,
                                        fontSize: layout.fontModuleTitle,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Image.asset(
                                      _ReportAssets.moon,
                                      width: layout.pt(72),
                                      height: layout.pt(60),
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                SizedBox(height: layout.sectionTitleGap),
                                SleepStagesChart(
                                  day: session.startedAt,
                                  segments: _toChartSegments(session.stages!),
                                  height: layout.pt(180),
                                  style: const SleepStagesStyle(
                                    stageColors: {
                                      SleepStage.deep: Color(0xFF4F9E63),
                                      SleepStage.light: Color(0xFF7BC99A),
                                      SleepStage.rem: Color(0xFF6B8CF5),
                                      SleepStage.awake: Color(0xFFE6A23C),
                                    },
                                    labelTextStyle: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF707070),
                                    ),
                                  ),
                                  labeler: (stage) => switch (stage) {
                                    SleepStage.deep => '深睡',
                                    SleepStage.light => '浅睡',
                                    SleepStage.rem => 'REM',
                                    SleepStage.awake => '清醒',
                                  },
                                ),
                                if (session.stages!.isNotEmpty) ...[
                                  SizedBox(height: layout.pt(10)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '入睡 ${_hm(session.stages!.first.start)}',
                                        style: TextStyle(
                                          color: _ReportTone.muted,
                                          fontSize: layout.fontAssist,
                                        ),
                                      ),
                                      Text(
                                        '醒来 ${_hm(session.stages!.last.end)}',
                                        style: TextStyle(
                                          color: _ReportTone.muted,
                                          fontSize: layout.fontAssist,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: layout.cardGap),
                        ],
                        _ScoreSurfaceCard(
                          layout: layout,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (session.qualityLabel != null)
                                Text(
                                  session.qualityLabel!,
                                  style: TextStyle(
                                    color: _ReportTone.accent,
                                    fontSize: layout.fontSecondaryTitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (session.score != null) ...[
                                SizedBox(height: layout.pt(6)),
                                Text(
                                  '睡眠分数 ${session.score}',
                                  style: TextStyle(
                                    color: _ReportTone.ink,
                                    fontSize: layout.fontCardTitle,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (session.insight != null) ...[
                                SizedBox(height: layout.pt(10)),
                                Text(
                                  session.insight!,
                                  style: TextStyle(
                                    color: _ReportTone.muted,
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
                                    color: _ReportTone.muted,
                                    fontSize: layout.fontAssist,
                                  ),
                                ),
                              ],
                              SizedBox(height: layout.pt(14)),
                              Text(
                                isReadOnly ? '历史评分' : '睡得怎么样？（可选）',
                                style: TextStyle(
                                  color: _ReportTone.ink,
                                  fontSize: layout.fontCardTitle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: layout.pt(4)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 1; i <= 5; i++)
                                    GestureDetector(
                                      onTap: isReadOnly
                                          ? null
                                          : () => _selectRating(session.id, i),
                                      child: Opacity(
                                        opacity:
                                            i <=
                                                (_rating ?? session.rating ?? 0)
                                            ? 1
                                            : 0.28,
                                        child: Image.asset(
                                          _ReportAssets.ratingStar,
                                          width: layout.pt(28),
                                          height: layout.pt(28),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: layout.cardGap),
                        _SurfaceCard(
                          layout: layout,
                          child: HeartRateCurvePanel(
                            layout: layout,
                            title: '夜间心率',
                            samples: _nightHr,
                            dark: false,
                            headerIconAsset: _ReportAssets.nightHeartRate,
                            emptyIconAsset: _ReportAssets.emptyHeartRate,
                            emptyHint: '曲线待同步。连接戒指同步后将在此展示。',
                          ),
                        ),
                        SizedBox(height: layout.moduleSpace),
                        _TodayWhiteNoiseSection(
                          layout: layout,
                          items: _whiteNoiseRecs,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectRating(String sessionId, int rating) async {
    setState(() => _rating = rating);
    try {
      await Get.find<SleepRepository>().saveRating(sessionId, rating);
    } catch (_) {}
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.layout,
    required this.mode,
    required this.onModeChanged,
    this.showMode = true,
  });

  final HealingLayout layout;
  final _ReportViewMode mode;
  final ValueChanged<_ReportViewMode> onModeChanged;
  final bool showMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.pt(44),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Icon(Icons.arrow_back_ios_new, size: layout.pt(18)),
            color: _ReportTone.ink,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: layout.pt(40),
              minHeight: layout.pt(40),
            ),
          ),
          Expanded(
            child: Text(
              '睡眠',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ReportTone.ink,
                fontSize: layout.fontSecondaryTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showMode)
            _ModeChip(layout: layout, mode: mode, onChanged: onModeChanged)
          else
            SizedBox(width: layout.pt(40)),
        ],
      ),
    );
  }
}

class _WeekBody extends StatelessWidget {
  const _WeekBody({
    required this.layout,
    required this.session,
    required this.weekBars,
    required this.onSelect,
  });

  final HealingLayout layout;
  final SleepSession session;
  final List<SleepWeekDayBar> weekBars;
  final ValueChanged<SleepWeekDayBar> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '本周睡眠时长',
          style: TextStyle(
            color: _ReportTone.ink,
            fontSize: layout.fontModuleTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: layout.sectionTitleGap),
        Text(
          '点选有数据的一天，查看该夜阶段与心率',
          style: TextStyle(
            color: _ReportTone.muted,
            fontSize: layout.fontAssist,
          ),
        ),
        SizedBox(height: layout.pt(16)),
        _SurfaceCard(
          layout: layout,
          child: SleepWeekDurationChart(
            layout: layout,
            days: weekBars,
            selectedId: SleepDay.idOf(session.startedAt),
            onSelect: onSelect,
            dark: false,
          ),
        ),
        if (weekBars.every((b) => !b.hasData)) ...[
          SizedBox(height: layout.pt(16)),
          Text(
            '近 7 个睡眠日暂无本地监测记录。完成睡眠监测后将出现在此。',
            style: TextStyle(
              color: _ReportTone.muted,
              fontSize: layout.fontAssist,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.layout, required this.child});

  final HealingLayout layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(layout.pt(16)),
      decoration: BoxDecoration(
        color: _ReportTone.card,
        borderRadius: BorderRadius.circular(layout.radiusContent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScoreSurfaceCard extends StatelessWidget {
  const _ScoreSurfaceCard({required this.layout, required this.child});

  final HealingLayout layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.radiusContent),
      child: Container(
        padding: EdgeInsets.all(layout.pt(16)),
        decoration: const BoxDecoration(
          color: _ReportTone.card,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -layout.pt(16),
              bottom: -layout.pt(16),
              width: layout.pt(220),
              child: IgnorePointer(
                child: Image.asset(
                  _ReportAssets.scoreCardBackground,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
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
        color: const Color(0xFFE8EEF8),
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
          color: selected ? _ReportTone.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _ReportTone.muted,
            fontSize: layout.fontAssist,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TodayWhiteNoiseSection extends StatelessWidget {
  const _TodayWhiteNoiseSection({required this.layout, required this.items});

  final HealingLayout layout;
  final List<SleepContentItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '今日推荐',
          style: TextStyle(
            color: _ReportTone.ink,
            fontSize: layout.fontModuleTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: layout.pt(4)),
        Text(
          '自然白噪音 · 助你更快入睡',
          style: TextStyle(
            color: _ReportTone.muted,
            fontSize: layout.fontAssist,
          ),
        ),
        SizedBox(height: layout.sectionTitleGap),
        for (final item in items) ...[
          _WhiteNoiseTile(layout: layout, item: item),
          SizedBox(height: layout.cardGap),
        ],
      ],
    );
  }
}

class _WhiteNoiseTile extends StatelessWidget {
  const _WhiteNoiseTile({required this.layout, required this.item});

  final HealingLayout layout;
  final SleepContentItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ReportTone.card,
      borderRadius: BorderRadius.circular(layout.radiusDepart),
      child: InkWell(
        onTap: () => openSleepContent(item),
        borderRadius: BorderRadius.circular(layout.radiusDepart),
        child: Padding(
          padding: EdgeInsets.all(layout.pt(12)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(layout.pt(8)),
                child: Image.asset(
                  item.coverImageAsset,
                  width: layout.pt(56),
                  height: layout.pt(56),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: layout.cardGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ReportTone.ink,
                        fontSize: layout.fontCardTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: layout.pt(4)),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ReportTone.muted,
                        fontSize: layout.fontAssist,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _ReportTone.muted,
                size: layout.pt(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
