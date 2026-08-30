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
      return const Scaffold(
        body: Center(child: Text('无报告数据')),
      );
    }
    final minutes = session.duration.inMinutes;
    final isReadOnly = session.rating != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('基础报告'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '在床约 $minutes 分钟',
              style: HealingDesignSystem.pageTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              '此为时长估计，非医疗诊断。',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Text(
              isReadOnly ? '历史评分' : '今晚感觉如何？',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 1; i <= 5; i++)
                  ChoiceChip(
                    label: Text('$i'),
                    selected: (_rating ?? session.rating) == i,
                    onSelected: isReadOnly || _saving
                        ? null
                        : (_) => setState(() => _rating = i),
                  ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: isReadOnly
                  ? () => Get.until((route) => route.settings.name == '/home')
                  : _rating == null || _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            await Get.find<SleepRepository>().saveRating(
                              session.id,
                              _rating!,
                            );
                            if (!mounted) return;
                            Get.until((route) => route.settings.name == '/home');
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
              child: Text(
                isReadOnly
                    ? '返回首页'
                    : _saving
                        ? '保存中…'
                        : '完成',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
