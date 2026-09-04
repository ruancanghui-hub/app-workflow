import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../../core/design/healing_layout.dart';
import '../../../data/ble/yc_ble_ring_service.dart';
import '../device_connection_controller.dart';
import '../device_scan_controller.dart';

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  late final DeviceScanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      DeviceScanController(
        ble: Get.find<YcBleRingService>(),
        connection: Get.find<DeviceConnectionController>(),
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<DeviceScanController>()) {
      Get.delete<DeviceScanController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Obx(
                      () => _ScanStatus(
                        layout: layout,
                        scanning: _controller.isScanning.value,
                        onRefresh: _controller.startScan,
                      ),
                    ),
                    SizedBox(height: layout.pt(18)),
                    Obx(() {
                      final err = _controller.errorMessage.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(bottom: layout.pt(12)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            err,
                            style: TextStyle(
                              color: const Color(0xFFFFBB55),
                              fontSize: layout.fontAssist,
                            ),
                          ),
                        ),
                      );
                    }),
                    Expanded(
                      child: Obx(() {
                        final items = _controller.devices;
                        if (items.isEmpty && !_controller.isScanning.value) {
                          return Center(
                            child: Text(
                              '附近暂无设备',
                              style: TextStyle(
                                color: const Color(0xFFD0D4DD),
                                fontSize: layout.fontCardTitle,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: layout.pt(14)),
                          itemBuilder: (context, index) {
                            final device = items[index];
                            final id = device.deviceIdentifier.isNotEmpty
                                ? device.deviceIdentifier
                                : device.macAddress;
                            return Obx(
                              () => _DeviceCandidateCard(
                                layout: layout,
                                device: device,
                                connecting: _controller.isConnecting.value &&
                                    _controller.connectingId.value == id,
                                enabled: !_controller.isConnecting.value,
                                onTap: () => _controller.connectAt(index),
                              ),
                            );
                          },
                        );
                      }),
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
  const _ScanStatus({
    required this.layout,
    required this.scanning,
    required this.onRefresh,
  });

  final HealingLayout layout;
  final bool scanning;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        scanning ? '正在搜索附近设备' : '附近设备',
        style: TextStyle(
          color: const Color(0xFFD0D4DD),
          fontSize: layout.fontSecondaryTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(width: layout.pt(14)),
      if (scanning)
        SizedBox(
          width: layout.pt(22),
          height: layout.pt(22),
          child: const CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Color(0xFF55E1D4),
          ),
        ),
      const Spacer(),
      GestureDetector(
        onTap: scanning ? null : onRefresh,
        child: Text(
          '刷新',
          style: TextStyle(
            color: scanning
                ? const Color(0x5567E8C5)
                : const Color(0xFF67E8C5),
            fontSize: layout.fontCardTitle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _DeviceCandidateCard extends StatelessWidget {
  const _DeviceCandidateCard({
    required this.layout,
    required this.device,
    required this.onTap,
    required this.connecting,
    required this.enabled,
  });

  final HealingLayout layout;
  final BluetoothDevice device;
  final VoidCallback onTap;
  final bool connecting;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final name = device.name.trim().isEmpty
        ? (device.deviceModel?.trim().isNotEmpty == true
              ? device.deviceModel!
              : '未知设备')
        : device.name.trim();
    final detail = device.macAddress.isNotEmpty
        ? device.macAddress
        : device.deviceIdentifier;
    final signal = YcBleRingService.signalLabel(device.rssiValue);
    final signalColor = switch (YcBleRingService.signalTone(device.rssiValue)) {
      ColorishSignal.good => const Color(0xFF66EAA3),
      ColorishSignal.medium => const Color(0xFFFFBB55),
      ColorishSignal.weak => const Color(0xFFFF7B7B),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(layout.radiusContent + layout.pt(4)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: layout.pt(16),
            vertical: layout.pt(18),
          ),
          decoration: BoxDecoration(
            color: const Color(0xD9122945),
            borderRadius: BorderRadius.circular(
              layout.radiusContent + layout.pt(4),
            ),
            border: Border.all(color: const Color(0x4A8DA6C2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle + layout.pt(2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      SizedBox(height: layout.pt(8)),
                      Text(
                        detail,
                        style: TextStyle(
                          color: const Color(0xFFD1D5DF),
                          fontSize: layout.fontCardTitle,
                        ),
                      ),
                    ],
                    SizedBox(height: layout.pt(12)),
                    Text(
                      connecting ? '●  连接中…' : '●  $signal',
                      style: TextStyle(
                        color: connecting
                            ? const Color(0xFF55E1D4)
                            : signalColor,
                        fontSize: layout.fontCardTitle,
                      ),
                    ),
                  ],
                ),
              ),
              if (connecting)
                SizedBox(
                  width: layout.pt(28),
                  height: layout.pt(28),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF55E1D4),
                  ),
                )
              else
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
