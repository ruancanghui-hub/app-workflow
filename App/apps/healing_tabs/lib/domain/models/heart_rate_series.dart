/// 心率时序采样点（bpm）。
class HeartRateSample {
  const HeartRateSample({
    required this.at,
    required this.bpm,
  });

  final DateTime at;
  final int bpm;

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'bpm': bpm,
      };

  factory HeartRateSample.fromJson(Map<String, dynamic> json) =>
      HeartRateSample(
        at: DateTime.parse(json['at'] as String),
        bpm: json['bpm'] as int,
      );
}

/// 某一睡眠日的夜间心率曲线。
class NightHeartRateSeries {
  const NightHeartRateSeries({
    required this.sleepDayId,
    required this.sleepDayStart,
    required this.samples,
  });

  final String sleepDayId;
  final DateTime sleepDayStart;
  final List<HeartRateSample> samples;

  bool get hasSamples => samples.isNotEmpty;
}

/// 一次冥想播放留下的心率曲线记录。
class MeditationHeartRateRecord {
  const MeditationHeartRateRecord({
    required this.id,
    required this.contentId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.samples,
  });

  final String id;
  final String contentId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<HeartRateSample> samples;

  bool get hasSamples => samples.isNotEmpty;

  Duration get duration => endedAt.difference(startedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentId': contentId,
        'title': title,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'samples': samples.map((s) => s.toJson()).toList(),
      };

  factory MeditationHeartRateRecord.fromJson(Map<String, dynamic> json) =>
      MeditationHeartRateRecord(
        id: json['id'] as String,
        contentId: json['contentId'] as String,
        title: json['title'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        samples: (json['samples'] as List<dynamic>)
            .map((e) => HeartRateSample.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
