import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'remote_config.dart';

class FirebaseRemoteConfigAdapter implements RemoteConfig {
  FirebaseRemoteConfigAdapter({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> fetchAndActivate() async {
    await _remoteConfig.fetchAndActivate();
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _remoteConfig.getString(key);
    return value.isEmpty ? defaultValue : value;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    if (!_remoteConfig.getAll().containsKey(key)) return defaultValue;
    return _remoteConfig.getBool(key);
  }
}
