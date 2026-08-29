import 'package:healing_tabs/core/storage/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FakeKeyValueStore roundtrip', () async {
    final store = FakeKeyValueStore();
    await store.setString('k', 'v');
    expect(await store.getString('k'), 'v');
    await store.remove('k');
    expect(await store.getString('k'), isNull);
  });
}
