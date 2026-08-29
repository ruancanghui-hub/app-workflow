import 'package:healing_tabs/core/identity/app_instance_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fake identity reader returns seeded identity', () {
    const identity = AppInstanceIdentity(appId: 'a1', displayName: 'Demo');
    final reader = FakeAppInstanceIdentityReader(identity);
    expect(reader.read().appId, 'a1');
  });
}
