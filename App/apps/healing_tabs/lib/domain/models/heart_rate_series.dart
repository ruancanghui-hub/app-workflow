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

/// 某一睡眠日的夜间心率曲线（查看时从 Apple 健康拼装，不落本地样本）。
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

/// 一次冥想播放留下的记录：本地只存时间窗，曲线查看时再查健康数据。
class MeditationHeartRateRecord {
  const MeditationHeartRateRecord({
    required this.id,
    required this.contentId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    this.samples = const [],
  });

  final String id;
  final String contentId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;

  /// 查看时由仓储填充；持久化不含样本。
  final List<HeartRateSample> samples;

  bool get hasSamples => samples.isNotEmpty;

  Duration get duration => endedAt.difference(startedAt);

  MeditationHeartRateRecord copyWithSamples(List<HeartRateSample> samples) =>
      MeditationHeartRateRecord(
        id: id,
        contentId: contentId,
        title: title,
        startedAt: startedAt,
        endedAt: endedAt,
        samples: samples,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentId': contentId,
        'title': title,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
      };

  factory MeditationHeartRateRecord.fromJson(Map<String, dynamic> json) =>
      MeditationHeartRateRecord(
        id: json['id'] as String,
        contentId: json['contentId'] as String,
        title: json['title'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        samples: const [],
      );
}
