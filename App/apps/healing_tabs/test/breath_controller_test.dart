import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/features/breath/breath_controller.dart';

void main() {
  test('breath controller runs 4-7-8 phases', () {
    final controller = BreathController();
    controller.start();
    expect(controller.phase.value, BreathPhase.inhale);
    expect(controller.round.value, 1);
    controller.onClose();
  });
}
