/// Umeng U-App keys from dart-define (seeded by instance.config.yaml apply).
///
/// Leave keys empty in the committed template; fill via `instance.config.yaml`
/// (gitignored). Never commit real AppKeys.
class UmengConfig {
  const UmengConfig({
    required this.androidAppKey,
    required this.iosAppKey,
    required this.channel,
  });

  factory UmengConfig.fromEnvironment() => const UmengConfig(
        androidAppKey: String.fromEnvironment(
          'UMENG_ANDROID_APP_KEY',
          defaultValue: '',
        ),
        iosAppKey: String.fromEnvironment(
          'UMENG_IOS_APP_KEY',
          defaultValue: '',
        ),
        channel: String.fromEnvironment(
          'UMENG_CHANNEL',
          defaultValue: 'Flutter',
        ),
      );

  final String androidAppKey;
  final String iosAppKey;
  final String channel;

  bool get hasKeys =>
      androidAppKey.trim().isNotEmpty && iosAppKey.trim().isNotEmpty;
}
