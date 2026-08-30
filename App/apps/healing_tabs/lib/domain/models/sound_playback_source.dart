enum SoundSourceKind { bundled, remote }

/// 声景音频来源：包内 assets 或网站 CDN 相对路径。
class SoundPlaybackSource {
  const SoundPlaybackSource.bundled(this.path)
      : kind = SoundSourceKind.bundled;

  const SoundPlaybackSource.remote(this.path)
      : kind = SoundSourceKind.remote;

  final SoundSourceKind kind;

  /// bundled: `assets/sounds/<file>.mp3`；remote: CDN 上的相对路径（如 `fireplace.mp3`）。
  final String path;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'path': path,
      };

  factory SoundPlaybackSource.fromJson(Map<String, dynamic> json) {
    final kind = SoundSourceKind.values.byName(json['kind'] as String);
    return switch (kind) {
      SoundSourceKind.bundled =>
        SoundPlaybackSource.bundled(json['path'] as String),
      SoundSourceKind.remote =>
        SoundPlaybackSource.remote(json['path'] as String),
    };
  }
}
