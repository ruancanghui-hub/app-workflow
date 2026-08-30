import 'dart:convert';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/repositories/sound_repository.dart';
import 'remote_sound_api.dart';
import 'sound_catalog_data.dart';
import 'sound_catalog_sync.dart';

class SoundRepositoryImpl implements SoundRepository {
  SoundRepositoryImpl(this._store, this._remoteSoundApi);

  static const _favoritesKey = 'sound_favorites_v1';

  final KeyValueStore _store;
  final RemoteSoundApi _remoteSoundApi;

  List<SoundAsset> _catalog = List<SoundAsset>.from(kLaunchSoundCatalog);
  int? _serverAudioTotal;
  int? _serverAudioFetched;
  bool _syncAttempted = false;

  @override
  int? get serverAudioTotal => _serverAudioTotal;

  @override
  int? get serverAudioFetched => _serverAudioFetched;

  @override
  Future<List<SoundAsset>> listAll() async {
    if (!_syncAttempted) {
      _syncAttempted = true;
      await refreshFromServer();
    }
    return List<SoundAsset>.unmodifiable(_catalog);
  }

  @override
  Future<void> refreshFromServer() async {
    try {
      final page = await _remoteSoundApi.fetchAll();
      if (page == null) return;
      final result = mergeCatalogWithServer(page);
      _catalog = result.catalog;
      _serverAudioTotal = result.serverTotal;
      _serverAudioFetched = result.serverFiles;
    } catch (_) {
      _catalog = List<SoundAsset>.from(kLaunchSoundCatalog);
    }
  }

  @override
  Future<SoundAsset?> findById(String id) async {
    await listAll();
    for (final sound in _catalog) {
      if (sound.id == id) return sound;
    }
    return null;
  }

  @override
  Future<List<SoundAsset>> listFavorites() async {
    final all = await listAll();
    final ids = await _readFavoriteIds();
    return all.where((s) => ids.contains(s.id)).toList();
  }

  @override
  Future<void> toggleFavorite(String soundId) async {
    final ids = await _readFavoriteIds();
    if (ids.contains(soundId)) {
      ids.remove(soundId);
    } else {
      ids.add(soundId);
    }
    await _store.setString(_favoritesKey, jsonEncode(ids.toList()));
  }

  @override
  Future<bool> isFavorite(String soundId) async {
    final ids = await _readFavoriteIds();
    return ids.contains(soundId);
  }

  Future<Set<String>> _readFavoriteIds() async {
    final raw = await _store.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) return {};
    final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
    return list.toSet();
  }
}
