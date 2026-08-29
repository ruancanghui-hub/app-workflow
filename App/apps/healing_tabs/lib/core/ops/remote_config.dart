abstract class RemoteConfig {
  Future<void> fetchAndActivate();
  String getString(String key, {String defaultValue = ''});
  bool getBool(String key, {bool defaultValue = false});
}

extension RemoteConfigX on RemoteConfig {
  bool isFeatureEnabled(String flag, {bool defaultValue = false}) =>
      getBool(flag, defaultValue: defaultValue);
}

class FakeRemoteConfig implements RemoteConfig {
  FakeRemoteConfig([Map<String, Object>? seed])
      : _values = Map<String, Object>.from(seed ?? const {});

  final Map<String, Object> _values;

  void seed(String key, Object value) => _values[key] = value;

  @override
  Future<void> fetchAndActivate() async {}

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _values[key];
    if (v == null) return defaultValue;
    return v.toString();
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final v = _values[key];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return defaultValue;
  }
}
