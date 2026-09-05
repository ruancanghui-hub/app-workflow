import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../domain/models/heart_rate_series.dart';
import '../../domain/models/sleep_day.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import 'yc_ble_ring_service.dart';

/// 播放/监测期间按 2 分钟轮询戒指心率并在结束时落库。
class PlaybackHeartRateSampler extends GetxService {
  PlaybackHeartRateSampler({
    required YcBleRingService ble,
    required HeartRateRepository heartRateRepository,
  })  : _ble = ble,
        _repo = heartRateRepository;

  final YcBleRingService _ble;
  final HeartRateRepository _repo;

  static const pollInterval = Duration(minutes: 2);
  static const firstSampleDelay = Duration(seconds: 5);

  Timer? _periodic;
  Timer? _firstShot;
  final _samples = <HeartRateSample>[];
  final _owners = <String>{};
  DateTime? _startedAt;
  String? _kind;
  String? _contentId;
  String? _title;
  var _active = false;

  bool get isActive => _active;

  /// [owner]：`player` | `sleepSession`；[kind]：`sleep` | `meditation`
  Future<void> begin({
    required String owner,
    required String kind,
    String? contentId,
    String? title,
  }) async {
    final linked = await _ble.refreshConnectedState();
    if (!linked) {
      debugPrint('[HR-Sampler] begin skipped: not connected');
      return;
    }
    _owners.add(owner);

    if (_active) {
      if (_kind == kind) {
        if (contentId != null) _contentId = contentId;
        if (title != null) _title = title;
        return;
      }
      // 种类切换（如冥想 → 睡眠）：先落库再开新会话。
      await _flushAndStopTimers();
    }

    _kind = kind;
    _contentId = contentId;
    _title = title;
    _startedAt = DateTime.now();
    _samples.clear();
    _active = true;
    _firstShot?.cancel();
    _periodic?.cancel();
    _firstShot = Timer(firstSampleDelay, () => unawaited(_tick()));
    _periodic = Timer.periodic(pollInterval, (_) => unawaited(_tick()));
    debugPrint('[HR-Sampler] begin owner=$owner kind=$kind');
  }

  /// 释放占用方；无占用时停表并落库。
  Future<void> end({required String owner}) async {
    _owners.remove(owner);
    if (_owners.isNotEmpty) return;
    await _flushAndStopTimers();
  }

  Future<void> _flushAndStopTimers() async {
    if (!_active && _samples.isEmpty) {
      _resetMeta();
      return;
    }
    _firstShot?.cancel();
    _firstShot = null;
    _periodic?.cancel();
    _periodic = null;
    await _tick();
    final kind = _kind;
    final started = _startedAt ?? DateTime.now();
    final ended = DateTime.now();
    final samples = List<HeartRateSample>.from(_samples);
    final contentId = _contentId ?? 'unknown';
    final title = _title ?? (kind == 'meditation' ? '冥想' : '睡眠');
    _resetMeta();

    if (samples.isEmpty) {
      debugPrint('[HR-Sampler] flush empty kind=$kind');
      return;
    }

    try {
      if (kind == 'meditation') {
        await _repo.saveMeditationRecord(
          MeditationHeartRateRecord(
            id: 'med_${started.millisecondsSinceEpoch}',
            contentId: contentId,
            title: title,
            startedAt: started,
            endedAt: ended,
            samples: samples,
          ),
        );
        debugPrint('[HR-Sampler] saved meditation n=${samples.length}');
      } else {
        await _repo.appendNightSamples(SleepDay.startOf(started), samples);
        debugPrint('[HR-Sampler] appended night n=${samples.length}');
      }
    } catch (e, st) {
      debugPrint('[HR-Sampler] persist failed: $e\n$st');
    }
  }

  void _resetMeta() {
    _active = false;
    _kind = null;
    _contentId = null;
    _title = null;
    _startedAt = null;
    _samples.clear();
  }

  Future<void> _tick() async {
    if (!_active) return;
    if (!_ble.isConnected.value) return;
    final bpm = await _ble.queryLatestHeartRateBpm();
    if (bpm == null) return;
    final now = DateTime.now();
    if (_samples.isNotEmpty) {
      final last = _samples.last;
      if (last.bpm == bpm &&
          now.difference(last.at) < const Duration(seconds: 30)) {
        return;
      }
    }
    _samples.add(HeartRateSample(at: now, bpm: bpm));
    debugPrint('[HR-Sampler] sample bpm=$bpm n=${_samples.length}');
  }

  @override
  void onClose() {
    _firstShot?.cancel();
    _periodic?.cancel();
    super.onClose();
  }
}
