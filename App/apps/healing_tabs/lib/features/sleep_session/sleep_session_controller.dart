import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/audio/app_audio_coordinator.dart';
import '../../core/haptics/healing_haptics.dart';
import '../../data/ble/playback_heart_rate_sampler.dart';
import '../../data/ble/yc_ble_ring_service.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/sound_repository.dart';
import '../player/player_controller.dart';
import '../tabs/home/home_scene_catalog.dart';

class SleepSessionController extends GetxController {
  SleepSessionController({required SleepRepository sleepRepository})
    : _sleepRepository = sleepRepository;

  final SleepRepository _sleepRepository;

  final session = Rxn<SleepSession>();
  final elapsed = Duration.zero.obs;
  final pendingSoundId = RxnString('forest_stream');

  /// 起床闹钟（开监测 sheet 选择）。
  final wakeAlarmTime = const TimeOfDay(hour: 8, minute: 0).obs;

  /// `null` = 智能停止；否则为伴睡音频定时分钟数。
  final timerMinutes = Rxn<int>(30);

  /// 单集循环直至定时结束。
  final singleLoopUntilTimer = true.obs;

  /// 墙钟（每秒刷新）。
  final wallClock = DateTime.now().obs;

  /// 定时窗起点（设置定时或开始监测时锚定）。
  final timerWindowStart = Rxn<DateTime>();

  /// 伴睡倒计时剩余秒；智能停止为 null。
  final companionRemainingSeconds = RxnInt();

  /// 已连接且有读数时显示；未连接为 null（隐藏 pill）。
  final liveBpm = RxnInt();
  final showHeartRate = false.obs;

  Timer? _sessionTick;
  Timer? _companionTick;
  DateTime? _companionDeadline;
  var _lastReminderBucket = -1;

  bool get isMonitoring => session.value?.status == SleepSessionStatus.active;

  String? get companionLabel => session.value?.soundId ?? pendingSoundId.value;

  /// 展示窗分钟：智能停止时用 30 作展示，不强制停播。
  int get displayWindowMinutes => timerMinutes.value ?? 30;

  String get timerWindowLabel {
    final start = timerWindowStart.value ?? wallClock.value;
    final end = start.add(Duration(minutes: displayWindowMinutes));
    return '${_fmtHm(start)}–${_fmtHm(end)}';
  }

  String get companionCountdownLabel {
    final mins = timerMinutes.value;
    if (mins == null) return '智能停止';
    final sec = companionRemainingSeconds.value;
    if (sec == null) {
      return '还剩 ${mins.toString().padLeft(2, '0')}:00';
    }
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '还剩 $m:$s';
  }

  String subtitleForSound(String? soundId) {
    if (Get.isRegistered<AppAudioCoordinator>()) {
      final sub = Get.find<AppAudioCoordinator>().nowPlayingSubtitle.value;
      if (sub != null && sub.isNotEmpty) return sub;
    }
    if (soundId == null) return '伴睡白噪音';
    for (final scene in HomeSceneCatalog.scenes) {
      if (scene.id == soundId) return scene.copy;
    }
    return '伴睡白噪音';
  }

  static String _fmtHm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void onClose() {
    _sessionTick?.cancel();
    _companionTick?.cancel();
    super.onClose();
  }

  Future<void> restoreActive() async {
    session.value = await _sleepRepository.activeSession();
    if (session.value != null) {
      timerWindowStart.value ??= DateTime.now();
      _startSessionTicker();
      _armCompanionTimer(resetWindow: false);
      unawaited(_setupHeartRate());
    } else {
      elapsed.value = Duration.zero;
    }
  }

  Future<void> start({String? soundId}) async {
    final resolved = soundId ?? pendingSoundId.value;
    session.value = await _sleepRepository.startSession(soundId: resolved);
    pendingSoundId.value = null;
    elapsed.value = Duration.zero;
    timerWindowStart.value = DateTime.now();
    _lastReminderBucket = -1;
    _startSessionTicker();
    _armCompanionTimer(resetWindow: true);
    // 心率与开播不阻塞进入监测页（避免 BLE/音频卡住导致无法跳转）。
    unawaited(_setupHeartRate());
    if (resolved != null && resolved.isNotEmpty) {
      unawaited(_playCompanionSafe(resolved));
    }
  }

  Future<void> _playCompanionSafe(String soundId) async {
    try {
      await _playCompanion(soundId);
    } catch (e, st) {
      debugPrint('[SleepSession] auto-play failed: $e\n$st');
    }
  }

  Future<void> _playCompanion(String soundId) async {
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final asset = await _resolveSoundAsset(soundId);
    if (asset == null) return;
    String? cover;
    for (final scene in HomeSceneCatalog.scenes) {
      if (scene.id == soundId) {
        cover = scene.backgroundAsset;
        break;
      }
    }
    await Get.find<AppAudioCoordinator>().playSoundAsset(
      soundId,
      asset,
      title: asset.title,
      subtitle: asset.subtitle,
      coverImageAsset: cover,
      scenario: 'sleep',
    );
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

  void setPendingCompanion(String soundId) {
    pendingSoundId.value = soundId;
  }

  void setWakeAlarmTime(TimeOfDay time) {
    wakeAlarmTime.value = time;
  }

  /// 从现在到起床闹钟的预计睡眠时长（跨天自动 +24h）。
  Duration estimatedSleepDuration({DateTime? from}) {
    final now = from ?? DateTime.now();
    final t = wakeAlarmTime.value;
    var wake = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    if (!wake.isAfter(now)) {
      wake = wake.add(const Duration(days: 1));
    }
    return wake.difference(now);
  }

  String estimatedSleepLabel({DateTime? from}) {
    final d = estimatedSleepDuration(from: from);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '预计睡眠：$hours 小时 $minutes 分钟';
  }

  Future<void> attachCompanion(String soundId) async {
    if (session.value == null) {
      await start(soundId: soundId);
      return;
    }
    await _sleepRepository.updateActiveSound(soundId);
    session.value = session.value!.copyWith(soundId: soundId);
  }

  void setTimerMinutes(int? minutes) {
    timerMinutes.value = minutes;
    timerWindowStart.value = DateTime.now();
    _lastReminderBucket = -1;
    _armCompanionTimer(resetWindow: true);
    if (minutes != null && Get.isRegistered<PlayerController>()) {
      Get.find<PlayerController>().setCountdownMinutes(minutes);
    }
  }

  void setSingleLoopUntilTimer(bool value) {
    singleLoopUntilTimer.value = value;
  }

  void _startSessionTicker() {
    _sessionTick?.cancel();
    _sessionTick = Timer.periodic(const Duration(seconds: 1), (_) {
      wallClock.value = DateTime.now();
      final current = session.value;
      if (current != null) {
        elapsed.value = current.duration;
        _maybeRemindEveryFiveMinutes();
      }
      _tickCompanionRemaining();
    });
  }

  void _maybeRemindEveryFiveMinutes() {
    final start = timerWindowStart.value;
    if (start == null) return;
    final elapsedMin = DateTime.now().difference(start).inMinutes;
    if (elapsedMin <= 0) return;
    if (elapsedMin > displayWindowMinutes) return;
    if (elapsedMin % 5 != 0) return;
    final bucket = elapsedMin ~/ 5;
    if (bucket == _lastReminderBucket) return;
    _lastReminderBucket = bucket;
    HealingHaptics.selection();
  }

  void _armCompanionTimer({required bool resetWindow}) {
    _companionTick?.cancel();
    _companionTick = null;
    final mins = timerMinutes.value;
    if (mins == null) {
      _companionDeadline = null;
      companionRemainingSeconds.value = null;
      return;
    }
    if (resetWindow || _companionDeadline == null) {
      _companionDeadline = DateTime.now().add(Duration(minutes: mins));
    }
    _tickCompanionRemaining();
  }

  void _tickCompanionRemaining() {
    final deadline = _companionDeadline;
    final mins = timerMinutes.value;
    if (mins == null || deadline == null) {
      companionRemainingSeconds.value = null;
      return;
    }
    final left = deadline.difference(DateTime.now()).inSeconds;
    if (left <= 0) {
      companionRemainingSeconds.value = 0;
      _companionDeadline = null;
      unawaited(_pauseCompanionAudio());
      return;
    }
    companionRemainingSeconds.value = left;
  }

  Future<void> _pauseCompanionAudio() async {
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final audio = Get.find<AppAudioCoordinator>();
    if (audio.hasPlayerSession && audio.isPlaying.value) {
      await audio.pause();
    }
  }

  Future<void> _setupHeartRate() async {
    liveBpm.value = null;
    showHeartRate.value = false;
    if (!Get.isRegistered<YcBleRingService>()) return;
    final ble = Get.find<YcBleRingService>();
    if (!ble.isConnected.value) {
      await _releaseHr();
      return;
    }
    showHeartRate.value = true;
    final ok = await ble.acquirePlaybackHeartRate(RingHrMonitorOwner.sleepSession);
    if (!ok) return;
    if (Get.isRegistered<PlaybackHeartRateSampler>()) {
      await Get.find<PlaybackHeartRateSampler>().begin(
        owner: 'sleepSession',
        kind: 'sleep',
        contentId: session.value?.id ?? 'sleep_monitor',
        title: '睡眠监测',
      );
    }
    final bpm = await ble.queryLatestHeartRateBpm();
    if (bpm != null) liveBpm.value = bpm;
    // 轻量轮询刷新 pill
    unawaited(_pollBpm());
  }

  Future<void> _pollBpm() async {
    if (!Get.isRegistered<YcBleRingService>()) return;
    final ble = Get.find<YcBleRingService>();
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (!isMonitoring || !showHeartRate.value) return;
      if (!ble.isConnected.value) {
        showHeartRate.value = false;
        liveBpm.value = null;
        return;
      }
      final bpm = await ble.queryLatestHeartRateBpm();
      if (bpm != null) liveBpm.value = bpm;
    }
  }

  Future<void> _releaseHr() async {
    if (Get.isRegistered<PlaybackHeartRateSampler>()) {
      await Get.find<PlaybackHeartRateSampler>().end(owner: 'sleepSession');
    }
    if (!Get.isRegistered<YcBleRingService>()) return;
    await Get.find<YcBleRingService>()
        .releasePlaybackHeartRate(RingHrMonitorOwner.sleepSession);
  }

  Future<SleepSession> endAndSave() async {
    _sessionTick?.cancel();
    _companionTick?.cancel();
    _companionDeadline = null;
    companionRemainingSeconds.value = null;
    if (Get.isRegistered<AppAudioCoordinator>()) {
      await Get.find<AppAudioCoordinator>().stopPlayer();
    }
    await _releaseHr();
    showHeartRate.value = false;
    liveBpm.value = null;
    final ended = await _sleepRepository.endSession();
    session.value = null;
    elapsed.value = Duration.zero;
    return ended;
  }
}
