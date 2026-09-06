import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/haptics/healing_haptics.dart';
import '../../tabs/home/home_scene_catalog.dart';
import '../sleep_session_controller.dart';

Future<void> showSleepStartSheet(BuildContext context) async {
  if (!Get.isRegistered<SleepSessionController>()) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _SleepStartSheet(),
  );
}

class _SleepStartSheet extends StatefulWidget {
  const _SleepStartSheet();

  @override
  State<_SleepStartSheet> createState() => _SleepStartSheetState();
}

class _SleepStartSheetState extends State<_SleepStartSheet> {
  late TimeOfDay _alarm;
  late String _soundId;
  var _starting = false;

  SleepSessionController get controller => Get.find<SleepSessionController>();

  @override
  void initState() {
    super.initState();
    _alarm = controller.wakeAlarmTime.value;
    _soundId =
        controller.pendingSoundId.value ?? HomeSceneCatalog.scenes.first.id;
    // Prefer forest_stream if default catalog has it.
    final hasForest = HomeSceneCatalog.scenes.any((s) => s.id == 'forest_stream');
    if (controller.pendingSoundId.value == null && hasForest) {
      _soundId = 'forest_stream';
    }
  }

  HomeScene get _scene {
    return HomeSceneCatalog.scenes.firstWhere(
      (s) => s.id == _soundId,
      orElse: () => HomeSceneCatalog.scenes.first,
    );
  }

  String get _estimatedLabel {
    final now = DateTime.now();
    var wake = DateTime(now.year, now.month, now.day, _alarm.hour, _alarm.minute);
    if (!wake.isAfter(now)) {
      wake = wake.add(const Duration(days: 1));
    }
    final d = wake.difference(now);
    return '预计睡眠：${d.inHours} 小时 ${d.inMinutes.remainder(60)} 分钟';
  }

  Future<void> _pickTheme() async {
    final scenes = HomeSceneCatalog.scenes;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF2A2F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '选择白噪音',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...scenes.map(
                (s) => ListTile(
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
                  onTap: () => Navigator.of(ctx).pop(s.id),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _soundId = picked);
    }
  }

  Future<void> _startSleep() async {
    if (_starting) return;
    setState(() => _starting = true);
    HealingHaptics.medium();
    try {
      controller.setWakeAlarmTime(_alarm);
      controller.setPendingCompanion(_soundId);
      await controller.start(soundId: _soundId);
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
      await Get.toNamed(AppRoutes.sleepSession);
    } catch (e, st) {
      debugPrint('[SleepStart] failed: $e\n$st');
      if (mounted) {
        setState(() => _starting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法开始睡眠，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
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
                '睡眠',
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
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(
                      2020,
                      1,
                      1,
                      _alarm.hour,
                      _alarm.minute,
                    ),
                    onDateTimeChanged: (dt) {
                      setState(() {
                        _alarm = TimeOfDay(hour: dt.hour, minute: dt.minute);
                      });
                    },
                  ),
                ),
              ),
              Text(
                _estimatedLabel,
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Material(
                color: const Color(0xFF1F2530),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: _pickTheme,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            _scene.backgroundAsset,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _scene.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '睡眠助手',
                                style: TextStyle(
                                  color: Color(0x99FFFFFF),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _starting ? null : _startSleep,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F28),
                    disabledBackgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: Text(
                    _starting ? '启动中…' : '开始睡眠',
                    style: const TextStyle(
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
