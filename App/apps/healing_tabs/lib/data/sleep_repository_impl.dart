import 'dart:convert';

import '../../core/storage/key_value_store.dart';
import '../../domain/models/sleep_session.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../features/sleep_session/sleep_report_builder.dart';
import '../../features/sleep_session/sleep_session_lifecycle.dart';

class SleepRepositoryImpl implements SleepRepository {
  SleepRepositoryImpl(this._store);

  static const _activeKey = 'sleep_active_session_v1';
  static const _historyKey = 'sleep_history_v1';

  final KeyValueStore _store;
  SleepSession? _active;

  @override
  Future<SleepSession> startSession({String? soundId}) async {
    final session = SleepSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      soundId: soundId,
    );
    _active = session;
    await _persistActive(session);
    return session;
  }

  @override
  Future<SleepSession?> activeSession() async {
    final session = await _readActiveRaw();
    if (session == null) return null;
    if (SleepSessionLifecycle.shouldAutoClose(session, DateTime.now())) {
      await endSession(status: SleepSessionStatus.completed);
      return null;
    }
    return session;
  }

  @override
  Future<void> updateActiveSound(String soundId) async {
    final current = await _readActiveRaw();
    if (current == null) {
      throw StateError('No active sleep session');
    }
    final updated = current.copyWith(soundId: soundId);
    _active = updated;
    await _persistActive(updated);
  }

  @override
  Future<SleepSession> endSession({
    SleepSessionStatus status = SleepSessionStatus.completed,
  }) async {
    final current = await _readActiveRaw();
    if (current == null) {
      throw StateError('No active sleep session');
    }
    final ended = SleepReportBuilder.enrich(
      current.copyWith(
        endedAt: DateTime.now(),
        status: status,
      ),
    );
    _active = null;
    await _store.remove(_activeKey);
    final history = await listHistory();
    history.insert(0, ended);
    await _store.setString(
      _historyKey,
      jsonEncode(history.map((s) => s.toJson()).toList()),
    );
    return ended;
  }

  @override
  Future<SleepSession> saveRating(String sessionId, int rating) async {
    final history = await listHistory();
    final index = history.indexWhere((s) => s.id == sessionId);
    if (index < 0) throw StateError('Session not found');
    final updated = history[index].copyWith(rating: rating);
    history[index] = updated;
    await _store.setString(
      _historyKey,
      jsonEncode(history.map((s) => s.toJson()).toList()),
    );
    return updated;
  }

  @override
  Future<List<SleepSession>> listHistory() async {
    final raw = await _store.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SleepSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SleepSession?> _readActiveRaw() async {
    if (_active != null) return _active;
    final raw = await _store.getString(_activeKey);
    if (raw == null) return null;
    final session = SleepSession.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    if (session.status == SleepSessionStatus.active) {
      _active = session;
      return session;
    }
    return null;
  }

  Future<void> _persistActive(SleepSession session) async {
    await _store.setString(_activeKey, jsonEncode(session.toJson()));
  }
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  static const _guestKey = 'settings_guest_v1';
  static const _notifyKey = 'settings_notify_v1';

  final KeyValueStore _store;

  @override
  Future<bool> isGuestMode() async {
    final raw = await _store.getString(_guestKey);
    return raw != 'false';
  }

  @override
  Future<void> setGuestMode(bool value) =>
      _store.setString(_guestKey, value.toString());

  @override
  Future<bool> notificationsEnabled() async {
    final raw = await _store.getString(_notifyKey);
    return raw == 'true';
  }

  @override
  Future<void> setNotificationsEnabled(bool value) =>
      _store.setString(_notifyKey, value.toString());
}
