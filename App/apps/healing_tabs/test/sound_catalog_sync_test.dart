import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/data/remote_sound_api.dart';
import 'package:healing_tabs/data/sound_catalog_sync.dart';
import 'package:healing_tabs/domain/models/sound_playback_source.dart';

void main() {
  test('merge maps server files to catalog ids', () {
    const page = RemoteSoundListPage(
      total: 5,
      page: 1,
      pageSize: 20,
      totalPages: 1,
      list: [
        RemoteSoundItem(
          name: 'shuiliu.mp3',
          size: 4422240,
          url: '/shuiliu.mp3',
        ),
        RemoteSoundItem(
          name:
              'freesound_community-amazon-jungle-day-crickets-birds-and-frogs-from-boat-on-river-great-spread2-some-occasional-boat-rocking-52759.mp3',
          size: 8371200,
          url:
              '/freesound_community-amazon-jungle-day-crickets-birds-and-frogs-from-boat-on-river-great-spread2-some-occasional-boat-rocking-52759.mp3',
        ),
      ],
    );

    final result = mergeCatalogWithServer(page);
    expect(result.serverTotal, 5);
    expect(result.serverFiles, 2);

    final ocean = result.catalog.firstWhere((s) => s.id == 'ocean_waves');
    expect(ocean.playback.kind, SoundSourceKind.remote);
    expect(ocean.playback.path, 'shuiliu.mp3');

    final valley = result.catalog.firstWhere((s) => s.id == 'valley_rain');
    expect(valley.playback.path, contains('amazon-jungle'));
  });
}
