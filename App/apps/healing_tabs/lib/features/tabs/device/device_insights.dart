import 'package:flutter/material.dart';

import '../../../core/design/healing_layout.dart';

class DeviceInsights extends StatelessWidget {
  const DeviceInsights({required this.layout, super.key});

  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.fromLTRB(
      layout.pagePad,
      layout.moduleSpace,
      layout.pagePad,
      0,
    ),
    padding: EdgeInsets.all(layout.pt(16)),
    decoration: BoxDecoration(
      color: const Color(0x33213B54),
      borderRadius: BorderRadius.circular(layout.radiusMember),
      border: Border.all(color: const Color(0x554B789A)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设备洞察',
          style: TextStyle(
            color: Colors.white,
            fontSize: layout.fontModuleTitle,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: layout.sectionTitleGap),
        _InsightRow(
          layout: layout,
          icon: 'assets/images/device/status/sleep_status.png',
          title: '睡眠监测',
          detail: '跟踪睡眠周期与深浅睡，帮你提升睡眠质量。',
        ),
        SizedBox(height: layout.cardGap),
        _InsightRow(
          layout: layout,
          icon: 'assets/images/device/status/heart_status.png',
          title: '心率监测',
          detail: '全天候监测心率变化，守护你的心脏健康。',
        ),
      ],
    ),
  );
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.layout,
    required this.icon,
    required this.title,
    required this.detail,
  });
  final HealingLayout layout;
  final String icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(layout.pt(12)),
    decoration: BoxDecoration(
      color: const Color(0x33233F5E),
      borderRadius: BorderRadius.circular(layout.radiusDepart),
    ),
    child: Row(
      children: [
        Image.asset(icon, width: layout.pt(36), height: layout.pt(36)),
        SizedBox(width: layout.cardGap),
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
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xB6D1DBED),
                  fontSize: layout.fontAssist,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xB6D1DBED),
          size: layout.pt(20),
        ),
      ],
    ),
  );
}
