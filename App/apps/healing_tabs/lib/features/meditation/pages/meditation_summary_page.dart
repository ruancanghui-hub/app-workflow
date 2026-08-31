import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeditationSummaryPage extends StatefulWidget {
  const MeditationSummaryPage({super.key});
  @override
  State<MeditationSummaryPage> createState() => _MeditationSummaryPageState();
}

class _MeditationSummaryPageState extends State<MeditationSummaryPage> {
  int? _emotion;
  final _labels = const ['平复', '放松', '仍有杂念'];
  @override
  Widget build(BuildContext context) {
    final minutes = (Get.arguments as int?) ?? 10;
    return Scaffold(
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
                  const Spacer(),
                  Image.asset(
                    'assets/images/sleep_meditation_v1/feature_art/meditation_leaf.png',
                    width: 90,
                    height: 90,
                  ),
                  const Text(
                    '练习完成',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$minutes分钟',
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 44),
                  const Text('现在感觉如何？', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (i) => ChoiceChip(
                        label: Text(_labels[i]),
                        selected: _emotion == i,
                        selectedColor: const Color(0x33E6A23C),
                        side: BorderSide(
                          color: _emotion == i
                              ? const Color(0xFFE6A23C)
                              : Colors.black26,
                          width: _emotion == i ? 2 : 1,
                        ),
                        onSelected: (_) => setState(() => _emotion = i),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _emotion == null
                          ? null
                          : () => Get.until(
                              (route) => route.settings.name == '/home',
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE6A23C),
                      ),
                      child: const Text('完成'),
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
