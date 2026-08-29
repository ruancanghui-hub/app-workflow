/// Build variant / runtime environment for the template instance.
enum BuildVariant { dev, prod }

abstract class AppEnvironment {
  BuildVariant get variant;
}

extension AppEnvironmentX on AppEnvironment {
  bool get isDev => variant == BuildVariant.dev;
  bool get isProd => variant == BuildVariant.prod;
}

class FakeAppEnvironment implements AppEnvironment {
  FakeAppEnvironment(this.variant);

  @override
  final BuildVariant variant;
}

/// Reads variant from `--dart-define=APP_VARIANT=dev|prod` (default: dev).
class DefineAppEnvironment implements AppEnvironment {
  const DefineAppEnvironment();

  static const _raw = String.fromEnvironment(
    'APP_VARIANT',
    defaultValue: 'dev',
  );

  @override
  BuildVariant get variant =>
      _raw.toLowerCase() == 'prod' ? BuildVariant.prod : BuildVariant.dev;
}
