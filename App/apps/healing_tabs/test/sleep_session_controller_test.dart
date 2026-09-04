import 'package:flutter_test/flutter_test.dart';
import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:healing_tabs/data/sleep_repository_impl.dart';
import 'package:healing_tabs/domain/models/sleep_session.dart';
import 'package:healing_tabs/features/sleep_session/sleep_session_controller.dart';

void main() {
  test('sleep session start end and rating', () async {
    final store = FakeKeyValueStore();
    final repo = SleepRepositoryImpl(store);
    final controller = SleepSessionController(sleepRepository: repo);

    await controller.start(soundId: 'valley_rain');
    expect(controller.session.value?.status, SleepSessionStatus.active);

    final ended = await controller.endAndSave();
    expect(ended.status, SleepSessionStatus.completed);
    expect(ended.soundId, 'valley_rain');
    expect(ended.stages, isNotEmpty);
    expect(ended.score, isNotNull);

    final rated = await repo.saveRating(ended.id, 4);
    expect(rated.rating, 4);
    controller.onClose();
  });
}
