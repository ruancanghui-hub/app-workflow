import '../core/storage/key_value_store.dart';
import '../domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._store);

  static const _pairedKey = 'device_paired_v1';

  final KeyValueStore _store;
  bool? _cached;

  @override
  Future<bool> isPaired() async {
    if (_cached != null) return _cached!;
    final raw = await _store.getString(_pairedKey);
    _cached = raw == 'true';
    return _cached!;
  }

  @override
  Future<void> setPaired(bool value) async {
    _cached = value;
    await _store.setString(_pairedKey, value.toString());
  }
}
