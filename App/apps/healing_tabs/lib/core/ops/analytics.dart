abstract class Analytics {
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}});
}

class FakeAnalytics implements Analytics {
  final events = <({String name, Map<String, Object?> parameters})>[];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    events.add((name: name, parameters: Map<String, Object?>.from(parameters)));
  }
}
