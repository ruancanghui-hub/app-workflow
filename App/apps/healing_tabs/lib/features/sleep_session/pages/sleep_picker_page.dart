import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../navigation/app_navigation.dart';

class SleepPickerPage extends StatelessWidget {
  const SleepPickerPage({super.key});

  static const _sounds = [
    ('山谷雨声', '自然 · 雨声', 'valley_rain'),
    ('海边浪声', '自然 · 海浪', 'ocean_waves'),
    ('林间风声', '自然 · 风声', 'pine_forest'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/sleep_meditation_v1/backgrounds/sleep_scene.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(decoration: BoxDecoration(color: Color(0x660A101A))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const Text(
                  '选择白噪音',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                ..._sounds.map(
                  (sound) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: ListTile(
                          tileColor: const Color(0x8C161C24),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x55B0A4FF),
                            child: Icon(
                              Icons.nights_stay_outlined,
                              color: Color(0xFFB0A4FF),
                            ),
                          ),
                          title: Text(
                            sound.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            sound.$2,
                            style: const TextStyle(color: Color(0xFFBAC1D2)),
                          ),
                          trailing: IconButton(
                            onPressed: () => openPlayer(sound.$3),
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: Color(0xFFB0A4FF),
                              size: 34,
                            ),
                          ),
                          onTap: () => openPlayer(sound.$3),
                        ),
                      ),
                    ),
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
