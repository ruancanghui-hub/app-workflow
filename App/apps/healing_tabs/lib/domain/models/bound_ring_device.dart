/// 本地持久化的已绑定戒指信息（来自 BLE 扫描结果）。
class BoundRingDevice {
  const BoundRingDevice({
    required this.macAddress,
    required this.deviceIdentifier,
    required this.name,
    this.rssiValue = 0,
    this.deviceModel,
  });

  final String macAddress;
  final String deviceIdentifier;
  final String name;
  final int rssiValue;
  final String? deviceModel;

  String get displayName {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final model = deviceModel?.trim();
    if (model != null && model.isNotEmpty) return model;
    return '云遥戒指';
  }

  Map<String, dynamic> toJson() => {
        'macAddress': macAddress,
        'deviceIdentifier': deviceIdentifier,
        'name': name,
        'rssiValue': rssiValue,
        'deviceModel': deviceModel ?? '',
      };

  factory BoundRingDevice.fromJson(Map<String, dynamic> json) =>
      BoundRingDevice(
        macAddress: json['macAddress'] as String? ?? '',
        deviceIdentifier: json['deviceIdentifier'] as String? ?? '',
        name: json['name'] as String? ?? '',
        rssiValue: json['rssiValue'] as int? ?? 0,
        deviceModel: (json['deviceModel'] as String?)?.trim().isEmpty == true
            ? null
            : json['deviceModel'] as String?,
      );
}

/// 从戒指同步并缓存的体征摘要。
class CachedDeviceMetrics {
  const CachedDeviceMetrics({
    required this.batteryPercent,
    this.sleepDuration,
    this.qualityLabel,
    this.insight,
    this.score,
    this.heartRateBpm,
    this.syncedAt,
  });

  final int batteryPercent;
  final Duration? sleepDuration;
  final String? qualityLabel;
  final String? insight;
  final int? score;
  final int? heartRateBpm;
  final DateTime? syncedAt;

  Map<String, dynamic> toJson() => {
        'batteryPercent': batteryPercent,
        'sleepDurationSec': sleepDuration?.inSeconds,
        'qualityLabel': qualityLabel,
        'insight': insight,
        'score': score,
        'heartRateBpm': heartRateBpm,
        'syncedAt': syncedAt?.toIso8601String(),
      };

  factory CachedDeviceMetrics.fromJson(Map<String, dynamic> json) {
    final sleepSec = json['sleepDurationSec'] as int?;
    final syncedRaw = json['syncedAt'] as String?;
    return CachedDeviceMetrics(
      batteryPercent: json['batteryPercent'] as int? ?? 0,
      sleepDuration:
          sleepSec == null ? null : Duration(seconds: sleepSec),
      qualityLabel: json['qualityLabel'] as String?,
      insight: json['insight'] as String?,
      score: json['score'] as int?,
      heartRateBpm: json['heartRateBpm'] as int?,
      syncedAt: syncedRaw == null ? null : DateTime.tryParse(syncedRaw),
    );
  }
}
