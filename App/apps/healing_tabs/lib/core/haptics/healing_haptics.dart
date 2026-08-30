import 'package:flutter/services.dart';

abstract final class HealingHaptics {
  static void selection() => _safe(HapticFeedback.selectionClick);

  static void light() => _safe(HapticFeedback.lightImpact);

  static void medium() => _safe(HapticFeedback.mediumImpact);

  static void _safe(void Function() feedback) {
    try {
      feedback();
    } on Object {
      // 单元测试环境无 ServicesBinding 时静默跳过。
    }
  }
}
