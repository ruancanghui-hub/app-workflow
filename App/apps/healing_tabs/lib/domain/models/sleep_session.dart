import 'sleep_stage_segment.dart';

enum SleepSessionStatus { active, completed, interrupted }

class SleepSession {
  const SleepSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.soundId,
    this.rating,
    this.status = SleepSessionStatus.active,
    this.qualityLabel,
    this.insight,
    this.score,
    this.stages,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? soundId;
  final int? rating;
  final SleepSessionStatus status;
  final String? qualityLabel;
  final String? insight;
  final int? score;
  final List<SleepStageSegment>? stages;

  Duration get duration =>
      (endedAt ?? DateTime.now()).difference(startedAt);

  SleepSession copyWith({
    DateTime? endedAt,
    int? rating,
    SleepSessionStatus? status,
    String? soundId,
    String? qualityLabel,
    String? insight,
    int? score,
    List<SleepStageSegment>? stages,
  }) =>
      SleepSession(
        id: id,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        soundId: soundId ?? this.soundId,
        rating: rating ?? this.rating,
        status: status ?? this.status,
        qualityLabel: qualityLabel ?? this.qualityLabel,
        insight: insight ?? this.insight,
        score: score ?? this.score,
        stages: stages ?? this.stages,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'soundId': soundId,
        'rating': rating,
        'status': status.name,
        'qualityLabel': qualityLabel,
        'insight': insight,
        'score': score,
        'stages': stages?.map((s) => s.toJson()).toList(),
      };

  factory SleepSession.fromJson(Map<String, dynamic> json) => SleepSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] == null
            ? null
            : DateTime.parse(json['endedAt'] as String),
        soundId: json['soundId'] as String?,
        rating: json['rating'] as int?,
        status: SleepSessionStatus.values.byName(json['status'] as String),
        qualityLabel: json['qualityLabel'] as String?,
        insight: json['insight'] as String?,
        score: json['score'] as int?,
        stages: (json['stages'] as List<dynamic>?)
            ?.map(
              (e) => SleepStageSegment.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
