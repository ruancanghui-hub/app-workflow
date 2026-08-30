import '../domain/models/sound_asset.dart';
import '../domain/models/sound_playback_source.dart';

/// 从 `--dart-define=SOUND_CDN_BASE_URL=` 读取网站音频根地址。
String get soundCdnBaseUrl {
  const raw = String.fromEnvironment('SOUND_CDN_BASE_URL', defaultValue: '');
  return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
}

/// 将 [SoundAsset] 解析为 just_audio 可用的 URI 字符串。
String resolveSoundPlaybackUri(SoundAsset asset) {
  final source = asset.playback;
  return switch (source.kind) {
    SoundSourceKind.bundled => source.path,
    SoundSourceKind.remote => _resolveRemoteUri(source.path),
  };
}

String _resolveRemoteUri(String relativePath) {
  final base = soundCdnBaseUrl;
  if (base.isEmpty) {
    throw StateError('SOUND_CDN_BASE_URL is not configured for ${relativePath}');
  }
  final normalized = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
  return '$base/$normalized';
}
