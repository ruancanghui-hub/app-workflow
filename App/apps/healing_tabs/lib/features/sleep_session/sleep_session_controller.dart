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
  final pendingSoundId = Rxn<String>();
  Timer? _timer;

  bool get isMonitoring => session.value?.status == SleepSessionStatus.active;

  String? get companionLabel => session.value?.soundId ?? pendingSoundId.value;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> restoreActive() async {
    session.value = await _sleepRepository.activeSession();
    if (session.value != null) {
      _startTicker();
    } else {
      elapsed.value = Duration.zero;
    }
  }

  Future<void> start({String? soundId}) async {
    final resolved = soundId ?? pendingSoundId.value;
    session.value = await _sleepRepository.startSession(soundId: resolved);
    pendingSoundId.value = null;
    elapsed.value = Duration.zero;
    _startTicker();
  }

  void setPendingCompanion(String soundId) {
    pendingSoundId.value = soundId;
  }

  Future<void> attachCompanion(String soundId) async {
    if (session.value == null) {
      await start(soundId: soundId);
      return;
    }
    await _sleepRepository.updateActiveSound(soundId);
    session.value = session.value!.copyWith(soundId: soundId);
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
    elapsed.value = Duration.zero;
    return ended;
  }
}
