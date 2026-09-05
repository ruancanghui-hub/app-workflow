import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/audio/app_audio_coordinator.dart';
import '../../../core/design/healing_layout.dart';
import '../../../domain/models/device_content.dart';
import '../../device/device_connection_controller.dart';
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
    final device = Get.find<DeviceConnectionController>();
    return Obx(() {
      final snapshot = device.snapshot.value;
      return _DeviceTabBody(
        activeTab: activeTab,
        onTabSelected: onTabSelected,
        snapshot: snapshot,
        paired: device.paired.value,
        onToggleDemo: () async {
          if (device.paired.value) {
            await device.unpair();
          } else {
            await openDeviceSearch();
          }
        },
        onPair: openDeviceSearch,
      );
    });
  }
}

class _DeviceTabBody extends StatelessWidget {
  const _DeviceTabBody({
    required this.activeTab,
    required this.onTabSelected,
    required this.snapshot,
    required this.paired,
    required this.onToggleDemo,
    required this.onPair,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;
  final DeviceDaySnapshot snapshot;
  final bool paired;
  final VoidCallback onToggleDemo;
  final Future<void> Function() onPair;

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
          final snapshot = this.snapshot;

          return Stack(
          fit: StackFit.expand,
          children: [
            const _DeviceBackdrop(),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _TopBar(layout: layout)),
                SliverToBoxAdapter(
                  child: _ConnectionRow(
                    layout: layout,
                    device: snapshot.device,
                    paired: paired,
                    onToggleDemo: onToggleDemo,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Hero(
                    layout: layout,
                    snapshot: snapshot,
                    onPair: onPair,
                  ),
                ),
                if (!paired)
                  SliverToBoxAdapter(child: _RingBenefits(layout: layout)),
                if (paired &&
                    (snapshot.sleep != null || snapshot.heartRate != null)) ...[
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
                          if (snapshot.sleep != null)
                            Expanded(
                              child: _MetricCard(
                                layout: layout,
                                title: '昨夜睡眠',
                                value: _formatSleep(snapshot.sleep!),
                                hint: snapshot.sleep!.qualityLabel,
                                iconAsset:
                                    'assets/images/device/status/sleep_feature.png',
                                onTap: openRingSleepReport,
                              ),
                            ),
                          if (snapshot.sleep != null &&
                              snapshot.heartRate != null)
                            SizedBox(width: layout.cardGap),
                          if (snapshot.heartRate != null)
                            Expanded(
                              child: _MetricCard(
                                layout: layout,
                                title: snapshot.heartRate!.kindLabel,
                                value: '${snapshot.heartRate!.bpm}',
                                unit: 'bpm',
                                hint: snapshot.heartRate!.baselineHint,
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
                    child: _SectionTitle(layout: layout, title: '根据体征推荐'),
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
                        itemCount: DeviceContentCatalog.recommendations.length,
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
                      onSleepMonitoringTap: openSleepMonitoring,
                      onHeartRateTap: openHeartRateTrend,
                    ),
                  ),
                ],
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
        openSleepContent(SleepContentCatalog.categories.first.items.first);
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

  String _formatSleep(NightSleepSummary sleep) {
    final h = sleep.duration.inHours;
    final m = sleep.duration.inMinutes.remainder(60);
    return '$h小时$m分';
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
  const _TopBar({required this.layout});
  final HealingLayout layout;

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
        children: [
          Text(
            '戒指',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: layout.fontPageTitle,
              height: 1.15,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: openMePage,
            child: Container(
              width: layout.pt(76),
              height: layout.pt(76),
              padding: EdgeInsets.all(layout.pt(10)),
              decoration: BoxDecoration(
                color: const Color(0x33122645),
                borderRadius: BorderRadius.circular(layout.radiusContent),
                border: Border.all(color: const Color(0x667C91AD)),
              ),
              child: Image.asset(
                HealingAssets.profileOrb(HealingRootTab.device),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.layout,
    required this.device,
    required this.paired,
    required this.onToggleDemo,
  });

  final HealingLayout layout;
  final RingDevice device;
  final bool paired;
  final VoidCallback onToggleDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(8),
        layout.pagePad,
        layout.pt(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.pt(14),
              vertical: layout.pt(8),
            ),
            decoration: BoxDecoration(
              color: const Color(0x220E1B2E),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0x667C91AD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/device/status/bluetooth_status.png',
                  width: layout.pt(18),
                  height: layout.pt(18),
                ),
                SizedBox(width: layout.chipGap),
                Text(
                  paired ? '已连接 · 电量 ${device.batteryPercent}%' : '未配对',
                  style: TextStyle(
                    color: const Color(0xFFD7DAE2),
                    fontSize: layout.fontButton,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onToggleDemo,
            child: Text(
              paired ? '解除连接' : '搜索设备',
              style: TextStyle(
                color: const Color(0xFF76D48E),
                fontSize: layout.fontAssist,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.layout,
    required this.snapshot,
    required this.onPair,
  });

  final HealingLayout layout;
  final DeviceDaySnapshot snapshot;
  final VoidCallback onPair;

  @override
  Widget build(BuildContext context) {
    final paired = snapshot.device.isPaired;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(6),
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: SizedBox(
        height: layout.pt(paired ? 216 : 304),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/device/backgrounds/ring_aurora_lake.png',
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
                        child: _RingVisual(
                          layout: layout,
                          size: layout.pt(paired ? 96 : 92),
                        ),
                      ),
                    ),
                    SizedBox(height: layout.pt(8)),
                    Text(
                      paired ? snapshot.headline : '配对戒指后，同步睡眠与心率',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (!paired) ...[
                      SizedBox(height: layout.sectionTitleGap),
                      Text(
                        '记录整夜睡眠趋势与静息心率变化，陪你更安心入眠',
                        style: TextStyle(
                          color: const Color(0xBFD6DBE8),
                          fontSize: layout.fontIntro,
                        ),
                      ),
                      SizedBox(height: layout.pt(14)),
                      SizedBox(
                        width: double.infinity,
                        height: layout.pt(44),
                        child: FilledButton(
                          onPressed: onPair,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB2F2BB),
                            foregroundColor: const Color(0xFF102018),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: Text(
                            '配对戒指',
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

class _RingBenefits extends StatelessWidget {
  const _RingBenefits({required this.layout});

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
              child: _RingBenefitCard(
                layout: layout,
                iconAsset: 'assets/images/device/status/sleep_feature.png',
                title: '睡眠监测',
                detail: '追踪入睡、深睡、醒来节律',
              ),
            ),
            SizedBox(width: layout.cardGap),
            Expanded(
              child: _RingBenefitCard(
                layout: layout,
                iconAsset: 'assets/images/device/status/heart_feature.png',
                title: '心率监测',
                detail: '同步静息心率与夜间变化',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RingBenefitCard extends StatelessWidget {
  const _RingBenefitCard({
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

class _RingVisual extends StatelessWidget {
  const _RingVisual({required this.layout, this.size});
  final HealingLayout layout;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final dim = size ?? layout.pt(96);
    return SizedBox(
      width: dim,
      height: dim,
      child: CustomPaint(painter: _RingPainter()),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.42;
    final inner = size.width * 0.28;
    final ring = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFD8EFE0),
          Color(0xFF7BC99A),
          Color(0xFFB2F2BB),
          Color(0xFFD8EFE0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outer))
      ..style = PaintingStyle.stroke
      ..strokeWidth = outer - inner;
    canvas.drawCircle(center, (outer + inner) / 2, ring);
    canvas.drawCircle(
      center,
      outer + 6,
      Paint()
        ..color = const Color(0x33B2F2BB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
