import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/sound_repository.dart';
import '../../sound_catalog/widgets/sound_library_sheet.dart';

Future<void> showSettingsSheet(BuildContext context) async {
  final settings = Get.find<SettingsRepository>();
  final sounds = Get.find<SoundRepository>();
  var guest = await settings.isGuestMode();
  var notify = await settings.notificationsEnabled();
  await sounds.refreshFromServer();
  var serverTotal = sounds.serverAudioTotal;
  var serverFetched = sounds.serverAudioFetched;

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A2028),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ListTile(
                  title: const Text('服务器音频', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    serverTotal == null
                        ? '未连接音频服务器'
                        : '共 $serverTotal 首（已同步 $serverFetched 首）',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: () async {
                      await sounds.refreshFromServer();
                      if (context.mounted) {
                        setState(() {
                          serverTotal = sounds.serverAudioTotal;
                          serverFetched = sounds.serverAudioFetched;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('我的收藏', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    '查看已收藏的声景',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showSoundLibrarySheet(context);
                  },
                ),
                SwitchListTile(
                  title: const Text('游客模式', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    '无需注册即可使用核心功能',
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: guest,
                  onChanged: (v) async {
                    await settings.setGuestMode(v);
                    setState(() => guest = v);
                  },
                ),
                SwitchListTile(
                  title: const Text('通知提醒', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    '关闭后仍可使用伴睡，轻唤醒将降级',
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: notify,
                  onChanged: (v) async {
                    await settings.setNotificationsEnabled(v);
                    setState(() => notify = v);
                  },
                ),
                ListTile(
                  title: const Text('隐私说明', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    '数据默认保存在本机；非医疗诊断产品。',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: const Color(0xFF1A2028),
                        title: const Text(
                          '隐私说明',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          '云遥仅在本机保存睡眠会话、收藏与设置偏好。'
                          '音频可从你的服务器拉取播放，我们不会将睡眠数据用于医疗诊断。',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('知道了'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
