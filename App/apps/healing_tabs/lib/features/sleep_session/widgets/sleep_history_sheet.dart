import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/models/sleep_session.dart';
import '../../../domain/repositories/sleep_repository.dart';
import '../../navigation/app_navigation.dart';

Future<void> showSleepHistorySheet(BuildContext context) async {
  final repository = Get.find<SleepRepository>();
  final history = await repository.listHistory();
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF141A22),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return _SleepHistoryBody(sessions: history);
    },
  );
}

class _SleepHistoryBody extends StatelessWidget {
  const _SleepHistoryBody({required this.sessions});

  final List<SleepSession> sessions;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '睡眠记录',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                sessions.isEmpty ? '暂无记录' : '共 ${sessions.length} 次',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: sessions.isEmpty
                    ? const Center(
                        child: Text(
                          '结束一次睡眠会话后，记录会出现在这里',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0x1FFFFFFF),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final minutes = session.duration.inMinutes;
                          final rating = session.rating;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              _formatDate(session.startedAt),
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '在床约 $minutes 分钟'
                              '${rating != null ? ' · 评分 $rating' : ''}',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              openSleepReport(session);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime time) {
    final local = time.toLocal();
    return '${local.month}月${local.day}日 '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
