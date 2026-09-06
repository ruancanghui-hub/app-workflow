import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../sleep_session_controller.dart';

Future<void> showSleepCompanionTimerSheet(BuildContext context) async {
  final controller = Get.find<SleepSessionController>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF2A2F3A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _SleepCompanionTimerSheet(controller: controller),
  );
}

class _SleepCompanionTimerSheet extends StatelessWidget {
  const _SleepCompanionTimerSheet({required this.controller});

  final SleepSessionController controller;

  static const _options = <(String, int?)>[
    ('智能停止', null),
    ('5 分钟', 5),
    ('10 分钟', 10),
    ('15 分钟', 15),
    ('30 分钟', 30),
    ('45 分钟', 45),
  ];

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Obx(() {
            final selected = controller.timerMinutes.value;
            final loop = controller.singleLoopUntilTimer.value;
            return ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  '定时器',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._options.map((opt) {
                  final (label, minutes) = opt;
                  final isSelected = selected == minutes;
                  return ListTile(
                    onTap: () {
                      controller.setTimerMinutes(minutes);
                      Navigator.of(context).pop();
                    },
                    title: Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (minutes == null) ...[
                          const SizedBox(width: 6),
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedInformationCircle,
                            size: 16,
                            color: Colors.white54,
                          ),
                        ],
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  );
                }),
                const Divider(color: Color(0x33FFFFFF), height: 1),
                ListTile(
                  title: const Text(
                    '单集循环',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: const Text(
                    '循环播放直至定时结束',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  trailing: Switch.adaptive(
                    value: loop,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF9D91F2),
                    onChanged: controller.setSingleLoopUntilTimer,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
