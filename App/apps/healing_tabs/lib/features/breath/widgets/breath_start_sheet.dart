import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/haptics/healing_haptics.dart';
import '../../navigation/app_navigation.dart';

Future<void> showBreathStartSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _BreathStartSheet(),
  );
}

class _BreathStartSheet extends StatefulWidget {
  const _BreathStartSheet();

  @override
  State<_BreathStartSheet> createState() => _BreathStartSheetState();
}

class _BreathStartSheetState extends State<_BreathStartSheet> {
  static const _minMinutes = 1;
  static const _maxMinutes = 60;
  static const _defaultMinutes = 5;

  late int _minutes;
  late FixedExtentScrollController _minuteController;
  var _starting = false;

  @override
  void initState() {
    super.initState();
    _minutes = _defaultMinutes;
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes - _minMinutes,
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  Future<void> _startBreath() async {
    if (_starting) return;
    setState(() => _starting = true);
    HealingHaptics.medium();
    try {
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
      openBreath(minutes: _minutes);
    } catch (e, st) {
      debugPrint('[BreathStart] failed: $e\n$st');
      if (mounted) {
        setState(() => _starting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法开始呼吸练习，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final itemCount = _maxMinutes - _minMinutes + 1;
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
                '呼吸练习',
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
                      setState(() => _minutes = _minMinutes + index);
                    },
                    children: [
                      for (var i = 0; i < itemCount; i++)
                        Center(
                          child: Text(
                            '${_minMinutes + i} 分钟',
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
                '练习时长：$_minutes 分钟',
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
                  onPressed: _starting ? null : _startBreath,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F28),
                    disabledBackgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: Text(
                    _starting ? '启动中…' : '开始练习',
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
