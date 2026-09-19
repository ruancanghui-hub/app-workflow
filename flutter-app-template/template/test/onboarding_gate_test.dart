import 'package:app_template/core/branding/onboarding_gate.dart';
import 'package:app_template/core/storage/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeKeyValueStore store;

  setUp(() {
    store = FakeKeyValueStore();
  });

  test('shouldShow when never seen', () async {
    expect(await OnboardingGate.shouldShow(store, '1'), isTrue);
  });

  test('shouldShow false when same version marked', () async {
    await OnboardingGate.markSeen(store, '1');
    expect(await OnboardingGate.shouldShow(store, '1'), isFalse);
  });

  test('shouldShow true after version bump', () async {
    await OnboardingGate.markSeen(store, '1');
    expect(await OnboardingGate.shouldShow(store, '2'), isTrue);
  });

  test('reset clears seen version', () async {
    await OnboardingGate.markSeen(store, '1');
    await OnboardingGate.reset(store);
    expect(await OnboardingGate.shouldShow(store, '1'), isTrue);
  });
}
