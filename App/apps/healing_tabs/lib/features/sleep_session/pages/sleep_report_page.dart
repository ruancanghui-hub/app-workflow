import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_design_system.dart';
import '../../../domain/models/sleep_session.dart';
import '../../../domain/repositories/sleep_repository.dart';

class SleepReportPage extends StatefulWidget {
  const SleepReportPage({super.key});

  @override
  State<SleepReportPage> createState() => _SleepReportPageState();
}

class _SleepReportPageState extends State<SleepReportPage> {
  int? _rating;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final session = Get.arguments as SleepSession?;
    if (session == null) {
      return const Scaffold(body: Center(child: Text('无报告数据')));
    }
    final minutes = session.duration.inMinutes;
    final isReadOnly = session.rating != null;

    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/sleep_meditation_v1/backgrounds/sleep_player_scene.png',
            fit: BoxFit.cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xB80B1020)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    '本次睡眠',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${hours > 0 ? '$hours小时' : ''}$remaining分',
                    style: HealingDesignSystem.heroDisplay.copyWith(
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '伴睡声景：山谷雨声',
                    style: TextStyle(color: Color(0xFF9AA0B9)),
                  ),
                  const SizedBox(height: 54),
                  Text(
                    isReadOnly ? '历史评分' : '睡得怎么样？（可选）',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: isReadOnly || _saving
                              ? null
                              : () => setState(() => _rating = i),
                          icon: Icon(
                            i <= (_rating ?? session.rating ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFB0A4FF),
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isReadOnly
                          ? () => Get.until(
                              (route) => route.settings.name == '/home',
                            )
                          : _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              try {
                                if (_rating != null)
                                  await Get.find<SleepRepository>().saveRating(
                                    session.id,
                                    _rating!,
                                  );
                                if (mounted)
                                  Get.until(
                                    (route) => route.settings.name == '/home',
                                  );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9D91F2),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(_saving ? '保存中…' : '完成'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
