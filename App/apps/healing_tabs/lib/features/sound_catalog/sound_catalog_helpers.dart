import '../../domain/models/sound_asset.dart';

SoundAsset? pickSound(
  List<SoundAsset> sounds,
  String id, {
  int fallbackIndex = 0,
}) {
  for (final sound in sounds) {
    if (sound.id == id) return sound;
  }
  if (fallbackIndex >= 0 && fallbackIndex < sounds.length) {
    return sounds[fallbackIndex];
  }
  return sounds.isNotEmpty ? sounds.first : null;
}
