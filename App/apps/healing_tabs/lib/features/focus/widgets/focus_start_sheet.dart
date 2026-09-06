import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/haptics/healing_haptics.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/home/home_scene_catalog.dart';

Future<void> showFocusStartSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _FocusStartSheet(),
  );
}

class _FocusStartSheet extends StatefulWidget {
  const _FocusStartSheet();

  @override
  State<_FocusStartSheet> createState() => _FocusStartSheetState();
}

class _FocusStartSheetState extends State<_FocusStartSheet> {
  static const _minMinutes = 3;
  static const _maxMinutes = 180;
  static const _defaultMinutes = 15;

  late int _minutes;
  late String _soundId;
  late FixedExtentScrollController _minuteController;
  var _starting = false;

  @override
  void initState() {
    super.initState();
    _minutes = _defaultMinutes;
    _soundId = HomeSceneCatalog.scenes.any((s) => s.id == 'forest_stream')
        ? 'forest_stream'
        : HomeSceneCatalog.scenes.first.id;
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes - _minMinutes,
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  HomeScene get _scene {
    return HomeSceneCatalog.scenes.firstWhere(
      (s) => s.id == _soundId,
      orElse: () => HomeSceneCatalog.scenes.first,
    );
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

  Future<void> _startFocus() async {
    if (_starting) return;
    setState(() => _starting = true);
    HealingHaptics.medium();
    try {
      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
      await openFocusSession(soundId: _soundId, minutes: _minutes);
    } catch (e, st) {
      debugPrint('[FocusStart] failed: $e\n$st');
      if (mounted) {
        setState(() => _starting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法开始专注，请重试')),
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
                '心流专注',
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
                '专注时长：$_minutes 分钟',
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
                                '专注助手',
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
                  onPressed: _starting ? null : _startFocus,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A1F28),
                    disabledBackgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: Text(
                    _starting ? '启动中…' : '开始专注',
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
