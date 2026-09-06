import 'dart:async';

import 'package:get/get.dart';

import '../../core/audio/app_audio_coordinator.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/repositories/sound_repository.dart';
import '../tabs/home/home_scene_catalog.dart';

enum BreathPhase { inhale, hold, exhale, idle, done }

class BreathController extends GetxController {
  final phase = BreathPhase.idle.obs;
  final round = 0.obs;
  final secondsLeft = 0.obs;

  /// 整段练习剩余秒；0 表示未配置时长。
  final sessionRemainingSeconds = 0.obs;
  final sessionMinutes = 0.obs;

  /// 自然之声（首页常用场景）。
  final natureSoundId = 'forest_stream'.obs;

  static const totalRounds = 4;
  static const minSessionMinutes = 1;
  static const maxSessionMinutes = 60;

  Timer? _timer;
  var _autoStart = false;
  var _ownsNatureAudio = false;

  String get natureSoundTitle {
    for (final scene in HomeSceneCatalog.scenes) {
      if (scene.id == natureSoundId.value) return scene.title;
    }
    return '自然之声';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int && args > 0) {
      sessionMinutes.value = args.clamp(minSessionMinutes, maxSessionMinutes);
      sessionRemainingSeconds.value = sessionMinutes.value * 60;
      _autoStart = true;
    } else if (sessionMinutes.value <= 0) {
      // 练习页默认可改时长；无入参时给 5 分钟。
      sessionMinutes.value = 5;
      sessionRemainingSeconds.value = 5 * 60;
    }
    if (!HomeSceneCatalog.scenes.any((s) => s.id == natureSoundId.value) &&
        HomeSceneCatalog.scenes.isNotEmpty) {
      natureSoundId.value = HomeSceneCatalog.scenes.first.id;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (_autoStart) {
      _autoStart = false;
      start();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    unawaited(_stopNatureAudio());
    super.onClose();
  }

  void start() {
    round.value = 1;
    if (sessionMinutes.value > 0 && sessionRemainingSeconds.value <= 0) {
      sessionRemainingSeconds.value = sessionMinutes.value * 60;
    }
    unawaited(_playNatureAudio());
    _enterPhase(BreathPhase.inhale, 4);
  }

  void pause() {
    _timer?.cancel();
    if (phase.value != BreathPhase.done) {
      phase.value = BreathPhase.idle;
    }
    unawaited(_pauseNatureAudio());
  }

  /// 切换自然之声；练习中会立即换播。
  Future<void> setNatureSound(String soundId) async {
    if (!HomeSceneCatalog.scenes.any((s) => s.id == soundId)) return;
    natureSoundId.value = soundId;
    if (phase.value == BreathPhase.idle || phase.value == BreathPhase.done) {
      // 预览选中声音。
      await _playNatureAudio();
      return;
    }
    await _playNatureAudio();
  }

  /// 设置练习总时长（1–60 分钟），并刷新剩余时间。
  void setSessionMinutes(int minutes) {
    final m = minutes.clamp(minSessionMinutes, maxSessionMinutes);
    sessionMinutes.value = m;
    sessionRemainingSeconds.value = m * 60;
  }

  void _enterPhase(BreathPhase next, int seconds) {
    phase.value = next;
    secondsLeft.value = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sessionRemainingSeconds.value > 0) {
        sessionRemainingSeconds.value--;
        if (sessionRemainingSeconds.value <= 0) {
          timer.cancel();
          phase.value = BreathPhase.done;
          unawaited(_pauseNatureAudio());
          return;
        }
      }
      if (secondsLeft.value <= 1) {
        timer.cancel();
        _advance();
      } else {
        secondsLeft.value--;
      }
    });
  }

  void _advance() {
    if (sessionMinutes.value > 0 && sessionRemainingSeconds.value <= 0) {
      phase.value = BreathPhase.done;
      unawaited(_pauseNatureAudio());
      return;
    }
    switch (phase.value) {
      case BreathPhase.inhale:
        _enterPhase(BreathPhase.hold, 7);
      case BreathPhase.hold:
        _enterPhase(BreathPhase.exhale, 8);
      case BreathPhase.exhale:
        if (sessionMinutes.value > 0) {
          round.value++;
          _enterPhase(BreathPhase.inhale, 4);
        } else if (round.value >= totalRounds) {
          phase.value = BreathPhase.done;
          unawaited(_pauseNatureAudio());
        } else {
          round.value++;
          _enterPhase(BreathPhase.inhale, 4);
        }
      case BreathPhase.idle:
      case BreathPhase.done:
        break;
    }
  }

  Future<void> _playNatureAudio() async {
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final asset = await _resolveSoundAsset(natureSoundId.value);
    if (asset == null) return;
    String? cover;
    for (final scene in HomeSceneCatalog.scenes) {
      if (scene.id == natureSoundId.value) {
        cover = scene.backgroundAsset;
        break;
      }
    }
    await Get.find<AppAudioCoordinator>().playSoundAsset(
      natureSoundId.value,
      asset,
      title: asset.title,
      subtitle: asset.subtitle,
      coverImageAsset: cover,
      scenario: 'meditation',
    );
    _ownsNatureAudio = true;
  }

  Future<void> _pauseNatureAudio() async {
    if (!_ownsNatureAudio) return;
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final audio = Get.find<AppAudioCoordinator>();
    if (audio.activeContentId.value == natureSoundId.value) {
      await audio.pause();
    }
  }

  Future<void> _stopNatureAudio() async {
    if (!_ownsNatureAudio) return;
    _ownsNatureAudio = false;
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final audio = Get.find<AppAudioCoordinator>();
    if (audio.activeContentId.value == natureSoundId.value) {
      await audio.stopPlayer();
    }
  }

  Future<SoundAsset?> _resolveSoundAsset(String soundId) async {
    if (Get.isRegistered<SoundRepository>()) {
      final fromRepo = await Get.find<SoundRepository>().findById(soundId);
      if (fromRepo != null) return fromRepo;
    }
    for (final asset in HomeSceneCatalog.soundAssets) {
      if (asset.id == soundId) return asset;
    }
    return null;
  }

  String get sessionRemainingLabel {
    final sec = sessionRemainingSeconds.value;
    if (sec <= 0 && sessionMinutes.value <= 0) return '';
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel => switch (phase.value) {
        BreathPhase.inhale => '吸气',
        BreathPhase.hold => '屏息',
        BreathPhase.exhale => '呼气',
        BreathPhase.idle => '准备开始 4-7-8',
        BreathPhase.done => '完成',
      };
}
