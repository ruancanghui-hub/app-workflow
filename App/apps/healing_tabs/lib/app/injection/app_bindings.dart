import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/http/dio_http_client.dart';
import '../../core/http/http_client.dart' as app_http;
import '../../core/identity/app_instance_identity.dart';
import '../../core/logging/app_logger.dart';
import '../../core/ops/analytics.dart';
import '../../core/ops/crash_reporter.dart';
import '../../core/ops/firebase_analytics_adapter.dart';
import '../../core/ops/firebase_bootstrap.dart';
import '../../core/ops/firebase_config_detector.dart';
import '../../core/ops/firebase_crashlytics_adapter.dart';
import '../../core/ops/firebase_remote_config_adapter.dart';
import '../../core/ops/remote_config.dart';
import '../../core/ops_console/http_ops_console_reporter.dart';
import '../../core/ops_console/ops_console_reporter.dart';
import '../../core/storage/key_value_store.dart';

/// Root composition: ports + default adapters (fakes unless Firebase configured).
class AppBindings extends Bindings {
  AppBindings({
    required this.keyValueStore,
    this.forceFakeOps = false,
    this.opsConsoleBaseUrl = const String.fromEnvironment(
      'OPS_CONSOLE_BASE_URL',
      defaultValue: '',
    ),
  });

  final KeyValueStore keyValueStore;
  final bool forceFakeOps;
  final String opsConsoleBaseUrl;

  @override
  void dependencies() {
    final env = const DefineAppEnvironment();
    Get.put<AppEnvironment>(env, permanent: true);

    final identityReader = const DefineAppInstanceIdentityReader();
    final identity = identityReader.read();
    Get.put<AppInstanceIdentityReader>(identityReader, permanent: true);
    Get.put<AppInstanceIdentity>(identity, permanent: true);

    Get.put<app_http.HttpClient>(DioHttpClient(), permanent: true);
    Get.put<KeyValueStore>(keyValueStore, permanent: true);

    final detector = const FirebaseConfigDetector();
    Get.put<FirebaseBootstrap>(
      FirebaseBootstrap(detector: detector),
      permanent: true,
    );

    Get.put<Analytics>(FakeAnalytics(), permanent: true);
    Get.put<RemoteConfig>(
      FakeRemoteConfig({'demo_flag': true}),
      permanent: true,
    );
    Get.put<CrashReporter>(FakeCrashReporter(), permanent: true);
    Get.put<AppLogger>(
      ConsoleAppLogger(crashReporter: Get.find<CrashReporter>()),
      permanent: true,
    );

    if (opsConsoleBaseUrl.trim().isEmpty || forceFakeOps) {
      Get.put<OpsConsoleReporter>(
        FakeOpsConsoleReporter(identity),
        permanent: true,
      );
    } else {
      Get.put<OpsConsoleReporter>(
        HttpOpsConsoleReporter(
          httpClient: Get.find<app_http.HttpClient>(),
          identity: identity,
          baseUrl: opsConsoleBaseUrl,
        ),
        permanent: true,
      );
    }
  }

  static Future<void> wireFirebaseAdapters({bool forceFakeOps = false}) async {
    if (forceFakeOps) return;
    final bootstrap = Get.find<FirebaseBootstrap>();
    final ok = await bootstrap.ensureInitialized();
    if (!ok) return;
    Get
      ..delete<Analytics>(force: true)
      ..delete<RemoteConfig>(force: true)
      ..delete<CrashReporter>(force: true)
      ..delete<AppLogger>(force: true);
    Get.put<Analytics>(FirebaseAnalyticsAdapter(), permanent: true);
    Get.put<RemoteConfig>(FirebaseRemoteConfigAdapter(), permanent: true);
    Get.put<CrashReporter>(FirebaseCrashlyticsAdapter(), permanent: true);
    Get.put<AppLogger>(
      ConsoleAppLogger(crashReporter: Get.find<CrashReporter>()),
      permanent: true,
    );
  }
}
