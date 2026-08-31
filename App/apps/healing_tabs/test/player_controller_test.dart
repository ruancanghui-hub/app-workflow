import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/core/audio/app_audio_coordinator.dart';
import 'package:healing_tabs/core/http/http_client.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/data/remote_sound_api.dart';
import 'package:healing_tabs/data/sleep_repository_impl.dart';
import 'package:healing_tabs/data/sound_repository_impl.dart';
import 'package:healing_tabs/features/player/player_controller.dart';

import 'fake_sound_audio_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player loads sound and toggles play state', () async {
    final store = FakeKeyValueStore();
    final sounds = SoundRepositoryImpl(store, RemoteSoundApi(FakeHttpClient()));
    final sleep = SleepRepositoryImpl(store);
    final audio = FakeSoundAudioPlayer();
    final coordinator = AppAudioCoordinator(audio);
    final controller = PlayerController(
      soundRepository: sounds,
      sleepRepository: sleep,
      audioPlayer: audio,
      audioCoordinator: coordinator,
    );
    await controller.load('valley_rain');
    expect(controller.sound.value?.title, '山谷雨声');
    expect(audio.lastPrepared, isNull);
    expect(controller.status.value.name, 'paused');
    await controller.togglePlay();
    expect(audio.lastPrepared?.id, 'valley_rain');
    expect(controller.status.value.name, 'playing');
    expect(audio.isPlaying, isTrue);
    await controller.pauseForInterruption();
    expect(controller.status.value.name, 'paused');
    expect(controller.showResumeHint.value, isTrue);
    await controller.togglePlay();
    expect(controller.status.value.name, 'playing');
    controller.onClose();
    expect(audio.isPlaying, isTrue);
    audio.disposeForTest();
  });
}
