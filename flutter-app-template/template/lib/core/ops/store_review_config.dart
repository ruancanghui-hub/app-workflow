/// App Store / Play Store URLs from dart-define (instance.config.yaml).
class StoreReviewConfig {
  const StoreReviewConfig({
    required this.iosStoreUrl,
    required this.androidStoreUrl,
  });

  factory StoreReviewConfig.fromEnvironment() => const StoreReviewConfig(
        iosStoreUrl: String.fromEnvironment(
          'IOS_STORE_URL',
          defaultValue: '',
        ),
        androidStoreUrl: String.fromEnvironment(
          'ANDROID_STORE_URL',
          defaultValue: '',
        ),
      );

  final String iosStoreUrl;
  final String androidStoreUrl;
}
