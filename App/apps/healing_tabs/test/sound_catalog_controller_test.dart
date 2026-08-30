import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/core/http/http_client.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/data/remote_sound_api.dart';
import 'package:healing_tabs/data/sound_repository_impl.dart';
import 'package:healing_tabs/features/sound_catalog/sound_catalog_controller.dart';

void main() {
  test('sound catalog controller exposes server totals after load', () async {
    final repo = SoundRepositoryImpl(
      FakeKeyValueStore(),
      RemoteSoundApi(FakeHttpClient()),
    );
    final controller = SoundCatalogController(repo);
    await controller.load();
    expect(controller.sounds, isNotEmpty);
    expect(controller.isLoading.value, isFalse);
  });
}
