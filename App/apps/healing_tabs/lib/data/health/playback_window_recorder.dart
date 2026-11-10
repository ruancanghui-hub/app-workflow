import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../domain/models/heart_rate_series.dart';
import '../../domain/repositories/heart_rate_repository.dart';

/// 冥想播放时间窗记录器：开始记起点，结束落本地；不采心率。
class PlaybackWindowRecorder extends GetxService {
  PlaybackWindowRecorder({required HeartRateRepository heartRateRepository})
      : _repo = heartRateRepository;

  final HeartRateRepository _repo;

  DateTime? _startedAt;
  String? _contentId;
  String? _title;
  var _active = false;

  bool get isActive => _active;

  Future<void> begin({
    required String contentId,
    required String title,
  }) async {
    _contentId = contentId;
    _title = title;
    _startedAt = DateTime.now();
    _active = true;
    debugPrint('[PlaybackWindow] begin contentId=$contentId');
  }

  Future<void> end() async {
    if (!_active) return;
    final started = _startedAt ?? DateTime.now();
    final ended = DateTime.now();
    final contentId = _contentId ?? 'unknown';
    final title = _title ?? '冥想';
    _reset();
    if (!ended.isAfter(started)) return;
    try {
      await _repo.saveMeditationRecord(
        MeditationHeartRateRecord(
          id: 'med_${started.millisecondsSinceEpoch}',
          contentId: contentId,
          title: title,
          startedAt: started,
          endedAt: ended,
        ),
      );
      debugPrint('[PlaybackWindow] saved $contentId');
    } catch (e, st) {
      debugPrint('[PlaybackWindow] save failed: $e\n$st');
    }
  }

  void _reset() {
    _active = false;
    _startedAt = null;
    _contentId = null;
    _title = null;
  }
}
