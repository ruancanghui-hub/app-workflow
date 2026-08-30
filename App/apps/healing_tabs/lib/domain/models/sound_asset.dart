import 'sound_playback_source.dart';

class SoundAsset {
  const SoundAsset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.isFree,
    required this.durationMinutes,
    required this.playback,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool isFree;
  final int durationMinutes;
  final SoundPlaybackSource playback;
  final bool isFeatured;

  SoundAsset copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<String>? tags,
    bool? isFree,
    int? durationMinutes,
    SoundPlaybackSource? playback,
    bool? isFeatured,
  }) =>
      SoundAsset(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        tags: tags ?? this.tags,
        isFree: isFree ?? this.isFree,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        playback: playback ?? this.playback,
        isFeatured: isFeatured ?? this.isFeatured,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'tags': tags,
        'isFree': isFree,
        'durationMinutes': durationMinutes,
        'playback': playback.toJson(),
        'isFeatured': isFeatured,
      };

  factory SoundAsset.fromJson(Map<String, dynamic> json) => SoundAsset(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        tags: (json['tags'] as List<dynamic>).cast<String>(),
        isFree: json['isFree'] as bool,
        durationMinutes: json['durationMinutes'] as int,
        playback: SoundPlaybackSource.fromJson(
          json['playback'] as Map<String, dynamic>,
        ),
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}
