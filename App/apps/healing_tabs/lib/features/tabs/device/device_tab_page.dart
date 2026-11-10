import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/audio/app_audio_coordinator.dart';
import '../../../core/design/healing_layout.dart';
import '../../../core/widgets/cached_cover_image.dart';
import '../../../domain/models/device_content.dart';
import '../../device/rest_data_controller.dart';
import '../../navigation/app_navigation.dart';
import '../meditation/meditation_content_catalog.dart';
import '../sleep/sleep_content_catalog.dart';
import 'device_content_catalog.dart';
import 'device_insights.dart';

class DeviceTabPage extends StatelessWidget {
  const DeviceTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final rest = Get.find<RestDataController>();
    return Obx(() {
      final snapshot = rest.snapshot.value;
      final connected = rest.isConnected;
      return _DeviceTabBody(
        activeTab: activeTab,
        onTabSelected: onTabSelected,
        snapshot: snapshot,
        connected: connected,
        onConnect: () => rest.connectAppleHealth(),
        onRefresh: () => rest.refreshSnapshot(),
      );
    });
  }
}

class _DeviceTabBody extends StatelessWidget {
  const _DeviceTabBody({
    required this.activeTab,
    required this.onTabSelected,
    required this.snapshot,
    required this.connected,
    required this.onConnect,
    required this.onRefresh,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;
  final RestDaySnapshot snapshot;
  final bool connected;
  final Future<bool> Function() onConnect;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Obx(() {
          final audio = Get.find<AppAudioCoordinator>();
          final bottomSpace =
              layout.tabBarDockedHeight +
              layout.tabBarBottomInset(context) +
              layout.sz(28) +
              layout.miniPlayerClearance(visible: audio.hasPlayerSession);
          final hasData =
              snapshot.authState == HealthAuthState.connectedWithData;

          return Stack(
            fit: StackFit.expand,
            children: [
              const _DeviceBackdrop(),
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _TopBar(
                      layout: layout,
                      connected: connected,
                      onRefresh: connected ? onRefresh : null,
                    ),
                  ),
                  if (connected)
                    SliverToBoxAdapter(
                      child: _ConnectionRow(
                        layout: layout,
                        hasData: hasData,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _Hero(
                      layout: layout,
                      snapshot: snapshot,
                      connected: connected,
                      onConnect: onConnect,
                    ),
                  ),
                  if (!connected)
                    SliverToBoxAdapter(child: _RestBenefits(layout: layout))
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          layout.pagePad,
                          layout.pt(8),
                          layout.pagePad,
                          layout.pt(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                layout: layout,
                                title: '昨夜休息',
                                value: snapshot.sleep != null
                                    ? _formatSleep(snapshot.sleep!)
                                    : '--',
                                hint: snapshot.sleep?.displayInsight ??
                                    '等待 Apple 健康同步',
                                iconAsset:
                                    'assets/images/device/status/sleep_feature.png',
                                onTap: openRingSleepReport,
                              ),
                            ),
                            SizedBox(width: layout.cardGap),
                            Expanded(
                              child: _MetricCard(
                                layout: layout,
                                title: snapshot.heartRate?.isResting == true
                                    ? '静息心率'
                                    : '心率',
                                value: snapshot.heartRate != null
                                    ? '${snapshot.heartRate!.bpm}'
                                    : '--',
                                unit:
                                    snapshot.heartRate != null ? 'bpm' : null,
                                hint: snapshot.heartRate != null
                                    ? _heartHint(snapshot.heartRate!)
                                    : '来自 Apple 健康',
                                iconAsset:
                                    'assets/images/device/status/heart_feature.png',
                                onTap: openHeartRateTrend,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _SectionTitle(layout: layout, title: '推荐聆听'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: layout.pt(148),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.pagePad,
                          ),
                          itemCount:
                              DeviceContentCatalog.recommendations.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: layout.cardGap),
                          itemBuilder: (context, index) {
                            final action =
                                DeviceContentCatalog.recommendations[index];
                            return _RecommendCard(
                              layout: layout,
                              action: action,
                              onTap: () => _openRecommendation(action),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DeviceInsights(
                        layout: layout,
                        onSleepMonitoringTap: openRingSleepReport,
                        onHeartRateTap: openHeartRateTrend,
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        layout.pagePad,
                        layout.pt(16),
                        layout.pagePad,
                        0,
                      ),
                      child: Text(
                        '数据来自 Apple 健康，仅供放松参考，非医疗用途。',
                        style: TextStyle(
                          color: const Color(0x66D1DBED),
                          fontSize: layout.fontAssist,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  void _openRecommendation(DeviceContentAction action) {
    switch (action.kind) {
      case DeviceContentActionKind.sleep:
        final sleep = SleepContentCatalog.categories
            .expand((c) => c.items)
            .firstWhere(
              (item) => item.title == action.title,
              orElse: () => SleepContentCatalog.categories.first.items.first,
            );
        openSleepContent(sleep);
      case DeviceContentActionKind.meditation:
        final meditation = MeditationContentCatalog.categories
            .expand((c) => c.items)
            .firstWhere(
              (item) => item.title == action.title,
              orElse: () =>
                  MeditationContentCatalog.categories.first.items.first,
            );
        openMeditationContent(meditation);
    }
  }

  String _formatSleep(NightSleepData sleep) {
    final h = sleep.duration.inHours;
    final m = sleep.duration.inMinutes.remainder(60);
    return '$h小时$m分';
  }

  String _heartHint(HeartRatePoint point) {
    if (point.isResting) return '来自 Apple 健康 · 静息';
    final h = point.at.hour.toString().padLeft(2, '0');
    final m = point.at.minute.toString().padLeft(2, '0');
    return '最近 $h:$m · 来自 Apple 健康';
  }
}

class _DeviceBackdrop extends StatelessWidget {
  const _DeviceBackdrop();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF010B19), Color(0xFF031329), Color(0xFF010914)],
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.layout,
    required this.connected,
    this.onRefresh,
  });

  final HealingLayout layout;
  final bool connected;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        top + layout.pt(8),
        layout.pagePad,
        layout.pt(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '休息',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: layout.fontPageTitle,
                    height: 1.15,
                  ),
                ),
                if (connected && onRefresh != null) ...[
                  SizedBox(height: layout.pt(10)),
                  SizedBox(
                    height: layout.pt(36),
                    child: OutlinedButton(
                      onPressed: () => onRefresh?.call(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF76D48E),
                        side: const BorderSide(color: Color(0x6676D48E)),
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.pt(16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      child: Text(
                        '刷新',
                        style: TextStyle(
                          fontSize: layout.fontAssist,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: openMePage,
            child: Image.asset(
              HealingAssets.profileOrb(HealingRootTab.home),
              width: layout.pt(44),
              height: layout.pt(44),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({required this.layout, required this.hasData});

  final HealingLayout layout;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(8),
        layout.pagePad,
        layout.pt(8),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: layout.pt(14),
            vertical: layout.pt(8),
          ),
          decoration: BoxDecoration(
            color: const Color(0x220E1B2E),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0x667C91AD)),
          ),
          child: Text(
            hasData ? '已连接 Apple 健康 · 有数据' : '已连接 Apple 健康 · 暂无数据',
            style: TextStyle(
              color: const Color(0xFFD7DAE2),
              fontSize: layout.fontButton,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.layout,
    required this.snapshot,
    required this.connected,
    required this.onConnect,
  });

  final HealingLayout layout;
  final RestDaySnapshot snapshot;
  final bool connected;
  final Future<bool> Function() onConnect;

  @override
  Widget build(BuildContext context) {
    final noData =
        connected && snapshot.authState == HealthAuthState.connectedNoData;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(6),
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: SizedBox(
        height: layout.pt(connected && !noData ? 216 : 304),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedCoverImage(
                asset: 'assets/images/device/backgrounds/ring_aurora_lake.png',
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x660A1210), Color(0xCC07110E)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(layout.pt(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          color: const Color(0xFFB2F2BB),
                          size: layout.pt(connected ? 72 : 88),
                        ),
                      ),
                    ),
                    SizedBox(height: layout.pt(8)),
                    Text(
                      connected
                          ? snapshot.headline
                          : '连接 Apple 健康，查看本地休息摘要',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (!connected || noData) ...[
                      SizedBox(height: layout.sectionTitleGap),
                      Text(
                        noData
                            ? '佩戴 Apple Watch 入睡并开启睡眠追踪后，摘要会出现在这里。'
                            : '从 Apple 健康读取休息时长与心率，仅供放松参考，非医疗诊断',
                        style: TextStyle(
                          color: const Color(0xBFD6DBE8),
                          fontSize: layout.fontIntro,
                        ),
                      ),
                    ],
                    if (!connected) ...[
                      SizedBox(height: layout.pt(14)),
                      SizedBox(
                        width: double.infinity,
                        height: layout.pt(44),
                        child: FilledButton(
                          onPressed: () => onConnect(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB2F2BB),
                            foregroundColor: const Color(0xFF102018),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: Text(
                            '连接 Apple 健康',
                            style: TextStyle(
                              fontSize: layout.fontButton,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _RestBenefits extends StatelessWidget {
  const _RestBenefits({required this.layout});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      layout.pagePad,
      0,
      layout.pagePad,
      layout.moduleSpace,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✦ 连接后可获得',
          style: TextStyle(
            color: const Color(0xFF76CDA0),
            fontSize: layout.fontAssist,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: layout.sectionTitleGap),
        Row(
          children: [
            Expanded(
              child: _BenefitCard(
                layout: layout,
                iconAsset: 'assets/images/device/status/sleep_feature.png',
                title: '休息摘要',
                detail: '昨夜时长与阶段占比',
              ),
            ),
            SizedBox(width: layout.cardGap),
            Expanded(
              child: _BenefitCard(
                layout: layout,
                iconAsset: 'assets/images/device/status/heart_feature.png',
                title: '心率参考',
                detail: '静息与练习时段曲线',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.layout,
    required this.iconAsset,
    required this.title,
    required this.detail,
  });

  final HealingLayout layout;
  final String iconAsset;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    height: layout.pt(108),
    padding: EdgeInsets.all(layout.pt(12)),
    decoration: BoxDecoration(
      color: const Color(0x33132643),
      borderRadius: BorderRadius.circular(layout.radiusContent),
      border: Border.all(color: const Color(0x557C91AD)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(iconAsset, width: layout.pt(44), height: layout.pt(44)),
        SizedBox(width: layout.pt(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: layout.fontCardTitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: layout.pt(7)),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xAFC9D0DE),
                  fontSize: layout.fontAssist,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.layout,
    required this.title,
    required this.value,
    required this.hint,
    required this.iconAsset,
    this.unit,
    this.onTap,
  });

  final HealingLayout layout;
  final String title;
  final String value;
  final String? unit;
  final String hint;
  final String iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: layout.pt(112),
        padding: EdgeInsets.all(layout.pt(16)),
        decoration: BoxDecoration(
          color: const Color(0x331A2A24),
          borderRadius: BorderRadius.circular(layout.radiusContent),
          border: Border.all(color: const Color(0x44A8D5B8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  iconAsset,
                  width: layout.pt(22),
                  height: layout.pt(22),
                ),
                SizedBox(width: layout.chipGap),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xCCE8F5EC),
                      fontSize: layout.fontCardTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0x88FFFFFF),
                    size: layout.pt(20),
                  ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: layout.fontPageTitle,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
                if (unit != null) ...[
                  SizedBox(width: layout.pt(4)),
                  Padding(
                    padding: EdgeInsets.only(bottom: layout.pt(3)),
                    child: Text(
                      unit!,
                      style: TextStyle(
                        color: const Color(0x99B2F2BB),
                        fontSize: layout.fontAssist,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: layout.pt(6)),
            Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0x99E8F5EC),
                fontSize: layout.fontAssist,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.layout, required this.title});
  final HealingLayout layout;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      layout.pagePad,
      layout.moduleSpace,
      layout.pagePad,
      layout.sectionTitleGap,
    ),
    child: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: layout.fontModuleTitle,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({
    required this.layout,
    required this.action,
    required this.onTap,
  });

  final HealingLayout layout;
  final DeviceContentAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: layout.pt(140),
      padding: EdgeInsets.all(layout.pt(16)),
      decoration: BoxDecoration(
        color: const Color(0x3D1A2A24),
        borderRadius: BorderRadius.circular(layout.radiusContent),
        border: Border.all(color: const Color(0x44A8D5B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            action.kind == DeviceContentActionKind.sleep
                ? Icons.bedtime_rounded
                : Icons.self_improvement_rounded,
            color: const Color(0xFFB2F2BB),
            size: layout.pt(22),
          ),
          const Spacer(),
          Text(
            action.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: layout.fontCardTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: layout.pt(8)),
          Text(
            action.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0x99E8F5EC),
              fontSize: layout.fontAssist,
            ),
          ),
        ],
      ),
    ),
  );
}
