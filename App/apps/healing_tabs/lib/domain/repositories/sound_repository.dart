import '../models/sound_asset.dart';

abstract class SoundRepository {
  Future<List<SoundAsset>> listAll();

  Future<SoundAsset?> findById(String id);

  Future<List<SoundAsset>> listFavorites();

  Future<void> toggleFavorite(String soundId);

  Future<bool> isFavorite(String soundId);

  /// 服务器 `/api/list` 返回的 `total`；未同步成功时为 null。
  int? get serverAudioTotal;

  /// 本页实际拉取到的服务器文件数。
  int? get serverAudioFetched;

  /// 重新请求服务器并合并目录。
  Future<void> refreshFromServer();
}
