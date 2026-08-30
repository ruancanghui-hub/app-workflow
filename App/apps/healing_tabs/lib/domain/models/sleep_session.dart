enum SleepSessionStatus { active, completed, interrupted }

class SleepSession {
  const SleepSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.soundId,
    this.rating,
    this.status = SleepSessionStatus.active,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? soundId;
  final int? rating;
  final SleepSessionStatus status;

  Duration get duration =>
      (endedAt ?? DateTime.now()).difference(startedAt);

  SleepSession copyWith({
    DateTime? endedAt,
    int? rating,
    SleepSessionStatus? status,
  }) =>
      SleepSession(
        id: id,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        soundId: soundId,
        rating: rating ?? this.rating,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'soundId': soundId,
        'rating': rating,
        'status': status.name,
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
      );
}
