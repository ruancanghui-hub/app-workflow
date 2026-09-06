import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../tabs/home/home_scene_catalog.dart';
import '../breath_controller.dart';

Future<void> showBreathNatureSoundSheet(BuildContext context) async {
  final controller = Get.find<BreathController>();
  final scenes = HomeSceneCatalog.scenes;
  final picked = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: const Color(0xFF2A2F3A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.7;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '选择自然之声',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...scenes.map((s) {
                final selected = s.id == controller.natureSoundId.value;
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      s.backgroundAsset,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    s.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    s.copy,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(s.id),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
  if (picked != null) {
    await controller.setNatureSound(picked);
  }
}

Future<void> showBreathDurationSheet(BuildContext context) async {
  final controller = Get.find<BreathController>();
  final initial = controller.sessionMinutes.value.clamp(
    BreathController.minSessionMinutes,
    BreathController.maxSessionMinutes,
  );
  final selected = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _BreathDurationSheet(initialMinutes: initial),
  );
  if (selected != null) {
    controller.setSessionMinutes(selected);
  }
}

class _BreathDurationSheet extends StatefulWidget {
  const _BreathDurationSheet({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_BreathDurationSheet> createState() => _BreathDurationSheetState();
}

class _BreathDurationSheetState extends State<_BreathDurationSheet> {
  late int _minutes;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes - BreathController.minSessionMinutes,
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final itemCount = BreathController.maxSessionMinutes -
        BreathController.minSessionMinutes +
        1;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: Material(
        color: const Color(0xE6282E3A),
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '练习时长',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoPicker(
                    scrollController: _minuteController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(
                        () => _minutes =
                            BreathController.minSessionMinutes + index,
                      );
                    },
                    children: [
                      for (var i = 0; i < itemCount; i++)
                        Center(
                          child: Text(
                            '${BreathController.minSessionMinutes + i} 分钟',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Text(
                '将剩余时间设为 $_minutes 分钟',
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_minutes),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
