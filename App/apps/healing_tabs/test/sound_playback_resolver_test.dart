import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/data/sound_catalog_data.dart';
import 'package:healing_tabs/data/sound_playback_resolver.dart';
import 'package:healing_tabs/domain/models/sound_playback_source.dart';

void main() {
  test('bundled sounds resolve to asset paths', () {
    final asset = kLaunchSoundCatalog.first;
    expect(resolveSoundPlaybackUri(asset), startsWith('assets/sounds/'));
  });

  test('remote sound without CDN throws', () {
    final remote = kLaunchSoundCatalog.firstWhere(
      (s) => s.playback.kind == SoundSourceKind.remote,
    );
    expect(() => resolveSoundPlaybackUri(remote), throwsStateError);
  });
}
