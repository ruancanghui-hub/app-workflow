import 'package:flutter/material.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_layout.dart';
import '../../../domain/models/device_content.dart';
import '../../navigation/app_navigation.dart';
import '../meditation/meditation_content_catalog.dart';
import '../sleep/sleep_content_catalog.dart';
import 'device_content_catalog.dart';
import 'device_insights.dart';

class DeviceTabPage extends StatefulWidget {
  const DeviceTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  State<DeviceTabPage> createState() => _DeviceTabPageState();
}

class _DeviceTabPageState extends State<DeviceTabPage> {
  var _paired = true;

  DeviceDaySnapshot get _snapshot => _paired
      ? DeviceContentCatalog.pairedSnapshot
      : DeviceContentCatalog.unpairedSnapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        final bottomSpace =
            layout.tabBarDockedHeight +
            layout.tabBarBottomInset(context) +
            layout.sz(28);
        final snapshot = _snapshot;

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
                    paired: _paired,
                    onToggleDemo: () => setState(() => _paired = !_paired),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Hero(
                    layout: layout,
                    snapshot: snapshot,
                    onPair: () => setState(() => _paired = true),
                  ),
                ),
                if (_paired &&
                    snapshot.sleep != null &&
                    snapshot.heartRate != null) ...[
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
                              title: '昨夜睡眠',
                              value: _formatSleep(snapshot.sleep!),
                              hint: snapshot.sleep!.qualityLabel,
                              iconAsset:
                                  'assets/images/device/status/sleep_status.png',
                              onTap: openRingSleepReport,
                            ),
                          ),
                          SizedBox(width: layout.cardGap),
                          Expanded(
                            child: _MetricCard(
                              layout: layout,
                              title: snapshot.heartRate!.kindLabel,
                              value: '${snapshot.heartRate!.bpm}',
                              unit: 'bpm',
                              hint: snapshot.heartRate!.baselineHint,
                              iconAsset:
                                  'assets/images/device/status/heart_status.png',
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
                  SliverToBoxAdapter(child: DeviceInsights(layout: layout)),
                ],
                SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
              ],
            ),
          ],
        );
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
        colors: [Color(0xFF0B1210), Color(0xFF121A18), Color(0xFF0E1513)],
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
              width: layout.pt(44),
              height: layout.pt(44),
              padding: EdgeInsets.all(layout.pt(8)),
              decoration: BoxDecoration(
                color: const Color(0x331A2A24),
                borderRadius: BorderRadius.circular(layout.radiusContent),
                border: Border.all(color: const Color(0x55A8D5B8)),
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
    final label = paired ? '已连接 · 电量 ${device.batteryPercent}%' : '未配对';
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
              color: paired ? const Color(0x3348A36F) : const Color(0x33A36F48),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: paired
                    ? const Color(0x88B2F2BB)
                    : const Color(0x88E6C3A0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  paired
                      ? Icons.bluetooth_connected_rounded
                      : Icons.bluetooth_disabled_rounded,
                  color: paired
                      ? const Color(0xFFB2F2BB)
                      : const Color(0xFFE6C3A0),
                  size: layout.pt(16),
                ),
                SizedBox(width: layout.chipGap),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
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
              paired ? '演示未配对' : '演示已连接',
              style: TextStyle(
                color: const Color(0x99B2F2BB),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(6),
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: SizedBox(
        height: layout.pt(200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/device/backgrounds/device_insight_scene.png',
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
                    Align(
                      alignment: Alignment.center,
                      child: _RingVisual(layout: layout),
                    ),
                    const Spacer(),
                    Text(
                      snapshot.headline,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (!snapshot.device.isPaired) ...[
                      SizedBox(height: layout.sectionTitleGap),
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

class _RingVisual extends StatelessWidget {
  const _RingVisual({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final size = layout.pt(96);
    return SizedBox(
      width: size,
      height: size,
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
