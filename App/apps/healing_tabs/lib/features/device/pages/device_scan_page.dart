import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../device_connection_controller.dart';

/// 蓝牙接入前：演示候选列表（已去掉右上角图标与中间戒指图）。
class DeviceScanPage extends StatelessWidget {
  const DeviceScanPage({super.key});

  static const _candidates = [
    _RingCandidate(
      name: '智能戒指',
      detail: '可同步睡眠与心率',
      signal: '信号强 · 待连接',
      signalColor: Color(0xFF66EAA3),
      recommended: true,
    ),
    _RingCandidate(
      name: '睡眠戒指',
      detail: '支持睡眠监测',
      signal: '信号良好 · 待连接',
      signalColor: Color(0xFF66EAA3),
    ),
    _RingCandidate(
      name: '健康戒指',
      detail: '心率趋势 · 压力管理',
      signal: '信号一般 · 待连接',
      signalColor: Color(0xFFFFBB55),
    ),
    _RingCandidate(
      name: '轻盈戒指',
      detail: '轻巧佩戴 · 舒适无感',
      signal: '信号稳定 · 待连接',
      signalColor: Color(0xFF5197FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final device = Get.find<DeviceConnectionController>();
    return Scaffold(
      backgroundColor: const Color(0xFF020F24),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = HealingLayout(constraints.biggest);
          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF041832),
                  Color(0xFF03142B),
                  Color(0xFF020E21),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
                child: Column(
                  children: [
                    _ScanHeader(layout: layout),
                    SizedBox(height: layout.pt(30)),
                    _ScanStatus(layout: layout),
                    SizedBox(height: layout.pt(26)),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _candidates.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: layout.pt(14)),
                        itemBuilder: (context, index) => _DeviceCandidateCard(
                          layout: layout,
                          candidate: _candidates[index],
                          onTap: () async {
                            await device.pair();
                            if (context.mounted) Get.back<void>();
                          },
                        ),
                      ),
                    ),
                    _PairingTip(layout: layout),
                    SizedBox(height: layout.pt(18)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  const _ScanHeader({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: layout.pt(52),
    child: Row(
      children: [
        IconButton(
          onPressed: Get.back<void>,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFFF2F3F8),
            size: layout.pt(24),
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}

class _ScanStatus extends StatelessWidget {
  const _ScanStatus({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '发现附近的设备',
        style: TextStyle(
          color: const Color(0xFFD0D4DD),
          fontSize: layout.fontSecondaryTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(width: layout.pt(14)),
      SizedBox(
        width: layout.pt(22),
        height: layout.pt(22),
        child: const CircularProgressIndicator(
          strokeWidth: 2.2,
          color: Color(0xFF55E1D4),
        ),
      ),
      const Spacer(),
      Text(
        '刷新',
        style: TextStyle(
          color: const Color(0xFF67E8C5),
          fontSize: layout.fontCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _DeviceCandidateCard extends StatelessWidget {
  const _DeviceCandidateCard({
    required this.layout,
    required this.candidate,
    required this.onTap,
  });

  final HealingLayout layout;
  final _RingCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(layout.radiusContent + layout.pt(4)),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: layout.pt(16),
          vertical: layout.pt(18),
        ),
        decoration: BoxDecoration(
          color: candidate.recommended
              ? const Color(0xFF082641)
              : const Color(0xD9122945),
          borderRadius: BorderRadius.circular(
            layout.radiusContent + layout.pt(4),
          ),
          border: Border.all(
            color: candidate.recommended
                ? const Color(0xFF69E6DB)
                : const Color(0x4A8DA6C2),
            width: candidate.recommended ? 1.4 : 1,
          ),
          boxShadow: candidate.recommended
              ? const [BoxShadow(color: Color(0x4D4FE0D2), blurRadius: 18)]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          candidate.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: layout.fontSecondaryTitle + layout.pt(2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (candidate.recommended)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.pt(9),
                            vertical: layout.pt(4),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF138D83),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '推荐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: layout.fontAssist,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: layout.pt(8)),
                  Text(
                    candidate.detail,
                    style: TextStyle(
                      color: const Color(0xFFD1D5DF),
                      fontSize: layout.fontCardTitle,
                    ),
                  ),
                  SizedBox(height: layout.pt(12)),
                  Text(
                    '●  ${candidate.signal}',
                    style: TextStyle(
                      color: candidate.signalColor,
                      fontSize: layout.fontCardTitle,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: layout.pt(42),
              height: layout.pt(42),
              padding: EdgeInsets.all(layout.pt(12)),
              decoration: const BoxDecoration(
                color: Color(0x33425B77),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/device_scan/ui_controls/device_chevron.png',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PairingTip extends StatelessWidget {
  const _PairingTip({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: layout.pt(16)),
    child: Row(
      children: [
        Image.asset(
          'assets/images/device_scan/status/pairing_tip.png',
          width: layout.pt(30),
          height: layout.pt(30),
        ),
        SizedBox(width: layout.pt(12)),
        Expanded(
          child: Text(
            '请确保戒指处于开机并靠近手机，以便顺利连接。',
            style: TextStyle(
              color: const Color(0xFFD0D4DD),
              fontSize: layout.fontAssist,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RingCandidate {
  const _RingCandidate({
    required this.name,
    required this.detail,
    required this.signal,
    required this.signalColor,
    this.recommended = false,
  });

  final String name;
  final String detail;
  final String signal;
  final Color signalColor;
  final bool recommended;
}
