import 'dart:async';

import 'package:get/get.dart';

enum BreathPhase { inhale, hold, exhale, idle, done }

class BreathController extends GetxController {
  final phase = BreathPhase.idle.obs;
  final round = 0.obs;
  final secondsLeft = 0.obs;

  static const totalRounds = 4;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void start() {
    round.value = 1;
    _enterPhase(BreathPhase.inhale, 4);
  }

  void pause() {
    _timer?.cancel();
    if (phase.value != BreathPhase.done) {
      phase.value = BreathPhase.idle;
    }
  }

  void _enterPhase(BreathPhase next, int seconds) {
    phase.value = next;
    secondsLeft.value = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value <= 1) {
        timer.cancel();
        _advance();
      } else {
        secondsLeft.value--;
      }
    });
  }

  void _advance() {
    switch (phase.value) {
      case BreathPhase.inhale:
        _enterPhase(BreathPhase.hold, 7);
      case BreathPhase.hold:
        _enterPhase(BreathPhase.exhale, 8);
      case BreathPhase.exhale:
        if (round.value >= totalRounds) {
          phase.value = BreathPhase.done;
        } else {
          round.value++;
          _enterPhase(BreathPhase.inhale, 4);
        }
      case BreathPhase.idle:
      case BreathPhase.done:
        break;
    }
  }

  String get phaseLabel => switch (phase.value) {
        BreathPhase.inhale => '吸气',
        BreathPhase.hold => '屏息',
        BreathPhase.exhale => '呼气',
        BreathPhase.idle => '准备开始 4-7-8',
        BreathPhase.done => '完成',
      };
}
