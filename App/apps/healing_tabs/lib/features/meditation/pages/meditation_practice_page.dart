import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeditationPracticePage extends StatefulWidget {
  const MeditationPracticePage({super.key});

  @override
  State<MeditationPracticePage> createState() => _MeditationPracticePageState();
}

class _MeditationPracticePageState extends State<MeditationPracticePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);
  late final int _targetMinutes = (Get.arguments as int?) ?? 10;
  late int _remaining = _targetMinutes * 60;
  Timer? _ticker;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && _remaining > 0) setState(() => _remaining--);
      if (_remaining == 0) _finish();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _finish() {
    _ticker?.cancel();
    Get.offNamed('/meditation/summary', arguments: _targetMinutes);
  }

  Future<void> _confirmExit() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确定结束本次练习？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('继续练习'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('结束'),
          ),
        ],
      ),
    );
    if (end == true) _finish();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/sleep_meditation_v1/backgrounds/meditation_scene.png',
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _confirmExit,
                      icon: const Icon(Icons.close),
                    ),
                    Text(
                      '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _breath,
                  builder: (_, __) => Container(
                    width: 220 + 56 * _breath.value,
                    height: 220 + 56 * _breath.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE6A23C),
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33E6A23C), blurRadius: 32),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _paused ? '暂停' : '吸气',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color(0xFF2C3338),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('跟随节奏，慢慢呼吸', style: TextStyle(fontSize: 17)),
                const Spacer(),
                Text(
                  '背景：山谷雨声',
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 12),
                IconButton.filled(
                  onPressed: () => setState(() {
                    _paused = !_paused;
                    _paused ? _breath.stop() : _breath.repeat(reverse: true);
                  }),
                  icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A23C),
                    foregroundColor: Colors.white,
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
