import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/models/sound_asset.dart';
import '../domain/services/sound_audio_player.dart';
import 'sound_playback_resolver.dart';

class JustAudioPlayerService implements SoundAudioPlayer {
  JustAudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;
  var _sessionConfigured = false;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Future<Duration> get position async => _player.position;

  @override
  Duration? get duration => _player.duration;

  Future<void> _ensureSession() async {
    if (_sessionConfigured) return;
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    _sessionConfigured = true;
  }

  @override
  Future<void> prepare(SoundAsset asset) async {
    await _ensureSession();
    await stop();
    final uri = resolveSoundPlaybackUri(asset);
    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      await _player.setUrl(uri);
    } else {
      await _player.setAsset(uri);
    }
    // 白噪音等短素材循环播放；会话时长由播放器页定时器控制。
    await _player.setLoopMode(LoopMode.one);
  }

  @override
  Future<void> prepareAsset(String assetPath) async {
    await _ensureSession();
    await stop();
    await _player.setAsset(assetPath);
    await _player.setLoopMode(LoopMode.one);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();
}
