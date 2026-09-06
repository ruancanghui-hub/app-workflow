import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_audio_coordinator.dart';

/// Bridges [AppAudioCoordinator] to system lock-screen / notification controls.
class HealingAudioHandler extends BaseAudioHandler {
  AppAudioCoordinator? _coord;
  Worker? _playingWorker;
  Worker? _metaWorker;
  var _notificationPermissionAsked = false;
  String? _cachedCoverKey;
  Uri? _cachedArtUri;

  void attach(AppAudioCoordinator coordinator) {
    if (identical(_coord, coordinator)) return;
    _detachWorkers();
    _coord = coordinator;

    _playingWorker = ever(coordinator.isPlaying, (_) {
      unawaited(_publishState());
    });
    _metaWorker = everAll(
      [
        coordinator.activeOwner,
        coordinator.activeContentId,
        coordinator.nowPlayingTitle,
        coordinator.nowPlayingSubtitle,
        coordinator.nowPlayingCover,
      ],
      (_) {
        unawaited(_publishMediaAndState());
      },
    );

    unawaited(_publishMediaAndState());
  }

  void _detachWorkers() {
    _playingWorker?.dispose();
    _metaWorker?.dispose();
    _playingWorker = null;
    _metaWorker = null;
  }

  Future<void> ensureNotificationPermission() async {
    if (_notificationPermissionAsked) return;
    _notificationPermissionAsked = true;
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final status = await Permission.notification.status;
    if (status.isGranted || status.isLimited) return;
    await Permission.notification.request();
  }

  Future<Uri?> _resolveArtUri(String? cover) async {
    if (cover == null || cover.isEmpty) return null;
    if (cover.startsWith('http://') || cover.startsWith('https://')) {
      return Uri.tryParse(cover);
    }
    if (cover.startsWith('file://')) {
      return Uri.tryParse(cover);
    }
    if (identical(_cachedCoverKey, cover) && _cachedArtUri != null) {
      return _cachedArtUri;
    }
    try {
      final data = await rootBundle.load(cover);
      final bytes = data.buffer.asUint8List();
      final safe = cover.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final file = File('${Directory.systemTemp.path}/yunyao_media_$safe');
      if (!await file.exists() || await file.length() != bytes.length) {
        await file.writeAsBytes(bytes, flush: true);
      }
      final uri = Uri.file(file.path);
      _cachedCoverKey = cover;
      _cachedArtUri = uri;
      return uri;
    } catch (e, st) {
      debugPrint('[HealingAudio] art resolve failed: $e\n$st');
      return null;
    }
  }

  Future<void> _publishMediaAndState() async {
    final coord = _coord;
    if (coord == null) return;

    if (coord.hasPlayerSession &&
        (coord.nowPlayingTitle.value?.isNotEmpty ?? false)) {
      final id = coord.activeContentId.value ?? 'player';
      final artUri = await _resolveArtUri(coord.nowPlayingCover.value);
      mediaItem.add(
        MediaItem(
          id: id,
          title: coord.nowPlayingTitle.value!,
          artist: coord.nowPlayingSubtitle.value,
          album: '云遥',
          artUri: artUri,
          duration: coord.duration,
        ),
      );
    } else if (!coord.hasPlayerSession) {
      mediaItem.add(null);
    }

    await _publishState();
  }

  Future<void> _publishState() async {
    final coord = _coord;
    if (coord == null) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: const [],
          processingState: AudioProcessingState.idle,
          playing: false,
          updatePosition: Duration.zero,
        ),
      );
      return;
    }

    final hasSession = coord.hasPlayerSession;
    final playing = hasSession && coord.isPlaying.value;
    final position = hasSession ? await coord.position : Duration.zero;
    playbackState.add(
      PlaybackState(
        controls: hasSession
            ? [
                if (playing) MediaControl.pause else MediaControl.play,
                MediaControl.stop,
              ]
            : const [],
        androidCompactActionIndices: hasSession ? const [0, 1] : const [],
        processingState: hasSession
            ? AudioProcessingState.ready
            : AudioProcessingState.idle,
        playing: playing,
        updatePosition: position,
        speed: 1,
      ),
    );
  }

  @override
  Future<void> play() async {
    final coord = _coord;
    if (coord == null || !coord.hasPlayerSession) return;
    await ensureNotificationPermission();
    await coord.resume();
    await _publishState();
  }

  @override
  Future<void> pause() async {
    final coord = _coord;
    if (coord == null) return;
    await coord.pause();
    await _publishState();
  }

  @override
  Future<void> stop() async {
    final coord = _coord;
    if (coord == null) return;
    await coord.stopPlayer();
    await super.stop();
    await _publishMediaAndState();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}

Future<HealingAudioHandler> initHealingAudioService() {
  return AudioService.init(
    builder: HealingAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.nightelf.yunyao.audio',
      androidNotificationChannelName: '云遥播放',
      androidStopForegroundOnPause: false,
    ),
  );
}
