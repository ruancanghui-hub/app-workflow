import '../models/sleep_session.dart';

abstract class SleepRepository {
  Future<SleepSession> startSession({String? soundId});
  Future<SleepSession?> activeSession();
  Future<SleepSession> endSession({SleepSessionStatus status});
  Future<SleepSession> saveRating(String sessionId, int rating);
  Future<List<SleepSession>> listHistory();
}
