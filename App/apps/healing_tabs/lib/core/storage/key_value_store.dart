abstract class KeyValueStore {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
}

class FakeKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}
