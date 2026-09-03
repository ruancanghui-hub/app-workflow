import 'dart:convert';
import 'dart:math';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/local_account.dart';
import '../../domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl(this._store);

  static const _accountKey = 'local_account_v1';

  final KeyValueStore _store;

  @override
  Future<LocalAccount> ensureLocalAccount() async {
    final existing = await _read();
    if (existing != null) return existing;
    final created = LocalAccount(
      id: _newInstallId(),
      displayName: '云遥旅人',
      createdAt: DateTime.now(),
    );
    await _write(created);
    return created;
  }

  @override
  Future<LocalAccount> currentAccount() => ensureLocalAccount();

  @override
  Future<LocalAccount> updateDisplayName(String name) async {
    final current = await ensureLocalAccount();
    final trimmed = name.trim();
    final next = current.copyWith(
      displayName: trimmed.isEmpty ? current.displayName : trimmed,
    );
    await _write(next);
    return next;
  }

  Future<LocalAccount?> _read() async {
    final raw = await _store.getString(_accountKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LocalAccount(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? '云遥旅人',
        createdAt: DateTime.parse(json['createdAt'] as String),
        avatarAsset: json['avatarAsset'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(LocalAccount account) => _store.setString(
        _accountKey,
        jsonEncode({
          'id': account.id,
          'displayName': account.displayName,
          'createdAt': account.createdAt.toIso8601String(),
          'avatarAsset': account.avatarAsset,
        }),
      );

  /// 本机安装级稳定 ID（首次生成后持久化）。不依赖硬件广告标识，规避权限与重置问题。
  String _newInstallId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
