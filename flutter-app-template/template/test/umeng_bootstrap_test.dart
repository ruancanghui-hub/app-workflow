import 'package:app_template/core/env/app_environment.dart';
import 'package:app_template/core/ops/privacy_consent.dart';
import 'package:app_template/core/ops/umeng_bootstrap.dart';
import 'package:app_template/core/ops/umeng_config.dart';
import 'package:app_template/core/storage/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeKeyValueStore store;
  late List<String> inits;

  setUp(() {
    store = FakeKeyValueStore();
    inits = [];
  });

  UmengBootstrap bootstrapWithKeys() {
    final boot = UmengBootstrap(
      config: const UmengConfig(
        androidAppKey: 'android-key',
        iosAppKey: 'ios-key',
        channel: 'test',
      ),
    );
    boot.initOverride = (android, ios, channel) async {
      inits.add('$android|$ios|$channel');
    };
    return boot;
  }

  test('UmengConfig.hasKeys requires both platforms', () {
    expect(
      const UmengConfig(
        androidAppKey: 'a',
        iosAppKey: '',
        channel: 'Flutter',
      ).hasKeys,
      isFalse,
    );
    expect(
      const UmengConfig(
        androidAppKey: 'a',
        iosAppKey: 'b',
        channel: 'Flutter',
      ).hasKeys,
      isTrue,
    );
  });

  test('dev inits when keys present', () async {
    final boot = bootstrapWithKeys();
    final ok = await boot.tryInit(
      environment: FakeAppEnvironment(BuildVariant.dev),
      store: store,
    );
    expect(ok, isTrue);
    expect(boot.isInitialized, isTrue);
    expect(inits, ['android-key|ios-key|test']);
  });

  test('prod blocks without privacy consent', () async {
    final boot = bootstrapWithKeys();
    final ok = await boot.tryInit(
      environment: FakeAppEnvironment(BuildVariant.prod),
      store: store,
    );
    expect(ok, isFalse);
    expect(inits, isEmpty);
  });

  test('prod inits after privacy consent', () async {
    final boot = bootstrapWithKeys();
    await PrivacyConsent.accept(store);
    final ok = await boot.tryInit(
      environment: FakeAppEnvironment(BuildVariant.prod),
      store: store,
    );
    expect(ok, isTrue);
    expect(inits, hasLength(1));
  });

  test('empty keys never init', () async {
    final boot = UmengBootstrap(
      config: const UmengConfig(
        androidAppKey: '',
        iosAppKey: '',
        channel: 'Flutter',
      ),
    );
    boot.initOverride = (a, i, c) async => inits.add('x');
    final ok = await boot.tryInit(
      environment: FakeAppEnvironment(BuildVariant.dev),
      store: store,
    );
    expect(ok, isFalse);
    expect(inits, isEmpty);
  });

  test('PrivacyConsent accept and reset', () async {
    expect(await PrivacyConsent.isAccepted(store), isFalse);
    await PrivacyConsent.accept(store);
    expect(await PrivacyConsent.isAccepted(store), isTrue);
    await PrivacyConsent.reset(store);
    expect(await PrivacyConsent.isAccepted(store), isFalse);
  });
}
