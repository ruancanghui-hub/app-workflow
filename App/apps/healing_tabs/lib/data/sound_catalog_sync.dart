import '../domain/models/sound_asset.dart';
import '../domain/models/sound_playback_source.dart';
import 'remote_sound_api.dart';
import 'sound_catalog_data.dart';

/// 服务器文件名 → 静态目录 id（展示名/标签沿用静态配置）。
const kServerFileToCatalogId = <String, String>{
  'freesound_community-amazon-jungle-day-crickets-birds-and-frogs-from-boat-on-river-great-spread2-some-occasional-boat-rocking-52759.mp3':
      'valley_rain',
  'freesound_community-zablocie-forest-birds-nature-reserve-19018.mp3':
      'pine_forest',
  'freesound_community-birds-singing-in-and-leaves-rustling-with-the-wind-14557.mp3':
      'white_noise',
  'shuiliu.mp3': 'ocean_waves',
};

/// 服务器有、静态目录未收录时的补充元数据。
const kServerOnlyCatalog = <String, SoundAsset>{
  'freesound_community-forest-with-small-river-birds-and-nature-field-recording-6735.mp3':
      SoundAsset(
    id: 'forest_river',
    title: '林间溪流',
    subtitle: '自然 · 服务器',
    tags: ['自然', '溪流'],
    isFree: true,
    durationMinutes: 75,
    playback: SoundPlaybackSource.remote(
      'freesound_community-forest-with-small-river-birds-and-nature-field-recording-6735.mp3',
    ),
  ),
};

String? catalogFileName(SoundAsset asset) {
  return switch (asset.playback.kind) {
    SoundSourceKind.bundled => asset.playback.path.split('/').last,
    SoundSourceKind.remote => asset.playback.path.replaceFirst('/', ''),
  };
}

SoundCatalogSyncResult mergeCatalogWithServer(RemoteSoundListPage server) {
  final serverByName = {
    for (final item in server.list) item.name: item,
  };
  final consumed = <String>{};
  final staticById = {for (final s in kLaunchSoundCatalog) s.id: s};

  final merged = <SoundAsset>[];

  for (final item in server.list) {
    final catalogId = kServerFileToCatalogId[item.name];
    if (catalogId != null && staticById.containsKey(catalogId)) {
      consumed.add(item.name);
      merged.add(
        staticById[catalogId]!.copyWith(
          playback: SoundPlaybackSource.remote(item.name),
        ),
      );
      continue;
    }

    final preset = kServerOnlyCatalog[item.name];
    if (preset != null) {
      consumed.add(item.name);
      merged.add(
        preset.copyWith(
          playback: SoundPlaybackSource.remote(item.name),
        ),
      );
      continue;
    }

    consumed.add(item.name);
    merged.add(_fallbackAsset(item));
  }

  for (final asset in kLaunchSoundCatalog) {
    if (merged.any((s) => s.id == asset.id)) continue;
    merged.add(asset);
  }

  merged.sort((a, b) {
    final aOnServer = serverByName.containsKey(catalogFileName(a));
    final bOnServer = serverByName.containsKey(catalogFileName(b));
    if (aOnServer != bOnServer) return aOnServer ? -1 : 1;
    if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
    return a.title.compareTo(b.title);
  });

  return SoundCatalogSyncResult(
    catalog: merged,
    serverTotal: server.total,
    serverFiles: server.list.length,
    matchedOnServer: consumed.length,
  );
}

SoundAsset _fallbackAsset(RemoteSoundItem item) {
  final id = 'remote_${item.name.hashCode.abs()}';
  final title = item.name
      .replaceAll('.mp3', '')
      .replaceAll('freesound_community-', '')
      .replaceAll('-', ' ');
  return SoundAsset(
    id: id,
    title: title.length > 24 ? '${title.substring(0, 24)}…' : title,
    subtitle: '服务器 · ${_formatSize(item.size)}',
    tags: ['服务器'],
    isFree: true,
    durationMinutes: 60,
    playback: SoundPlaybackSource.remote(item.name),
  );
}

String _formatSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class SoundCatalogSyncResult {
  const SoundCatalogSyncResult({
    required this.catalog,
    required this.serverTotal,
    required this.serverFiles,
    required this.matchedOnServer,
  });

  final List<SoundAsset> catalog;
  final int serverTotal;
  final int serverFiles;
  final int matchedOnServer;
}
