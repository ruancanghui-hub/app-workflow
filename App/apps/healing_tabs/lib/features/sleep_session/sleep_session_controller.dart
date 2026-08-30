import 'dart:async';

import 'package:get/get.dart';

import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';

class SleepSessionController extends GetxController {
  SleepSessionController({required SleepRepository sleepRepository})
      : _sleepRepository = sleepRepository;

  final SleepRepository _sleepRepository;

  final session = Rxn<SleepSession>();
  final elapsed = Duration.zero.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> restoreActive() async {
    session.value = await _sleepRepository.activeSession();
    if (session.value != null) {
      _startTicker();
    }
  }

  Future<void> start({String? soundId}) async {
    session.value = await _sleepRepository.startSession(soundId: soundId);
    elapsed.value = Duration.zero;
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = session.value;
      if (current != null) {
        elapsed.value = current.duration;
      }
    });
  }

  Future<SleepSession> endAndSave() async {
    _timer?.cancel();
    final ended = await _sleepRepository.endSession();
    session.value = null;
    return ended;
  }
}
