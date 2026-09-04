enum SleepStageKind { deep, light, rem, awake }

class SleepStageSegment {
  const SleepStageSegment({
    required this.start,
    required this.end,
    required this.kind,
  });

  final DateTime start;
  final DateTime end;
  final SleepStageKind kind;

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'kind': kind.name,
      };

  factory SleepStageSegment.fromJson(Map<String, dynamic> json) =>
      SleepStageSegment(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        kind: SleepStageKind.values.byName(json['kind'] as String),
      );
}
