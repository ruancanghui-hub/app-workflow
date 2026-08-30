import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/core/http/http_client.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/data/remote_sound_api.dart';
import 'package:healing_tabs/data/sound_repository_impl.dart';

void main() {
  test('sound catalog has six launch assets with three free', () async {
    final repo = SoundRepositoryImpl(
      FakeKeyValueStore(),
      RemoteSoundApi(FakeHttpClient()),
    );
    final all = await repo.listAll();
    expect(all.length, 6);
    expect(all.where((s) => s.isFree).length, greaterThanOrEqualTo(3));
  });

  test('toggle favorite persists', () async {
    final store = FakeKeyValueStore();
    final repo = SoundRepositoryImpl(store, RemoteSoundApi(FakeHttpClient()));
    expect(await repo.isFavorite('valley_rain'), isFalse);
    await repo.toggleFavorite('valley_rain');
    expect(await repo.isFavorite('valley_rain'), isTrue);
    final repo2 = SoundRepositoryImpl(store, RemoteSoundApi(FakeHttpClient()));
    expect(await repo2.isFavorite('valley_rain'), isTrue);
  });
}
