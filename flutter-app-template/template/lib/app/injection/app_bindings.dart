import 'package:get/get.dart';

import '../../core/env/app_environment.dart';
import '../../core/http/dio_http_client.dart';
import '../../core/http/http_client.dart' as app_http;
import '../../core/identity/app_instance_identity.dart';
import '../../core/logging/app_logger.dart';
import '../../core/ops/analytics.dart';
import '../../core/ops/app_events.dart';
import '../../core/ops/crash_reporter.dart';
import '../../core/ops/diagnostics_access.dart';
import '../../core/ops/firebase_analytics_adapter.dart';
import '../../core/ops/firebase_bootstrap.dart';
import '../../core/ops/firebase_config_detector.dart';
import '../../core/ops/firebase_crashlytics_adapter.dart';
import '../../core/ops/firebase_remote_config_adapter.dart';
import '../../core/ops/jank_monitor.dart';
import '../../core/ops/privacy_consent.dart';
import '../../core/ops/remote_config.dart';
import '../../core/ops/store_review_config.dart';
import '../../core/ops/umeng_analytics_adapter.dart';
import '../../core/ops/umeng_bootstrap.dart';
import '../../core/ops/umeng_config.dart';
import '../../core/ops_console/http_ops_console_reporter.dart';
import '../../core/ops_console/ops_console_reporter.dart';
import '../../core/storage/key_value_store.dart';

/// Root composition: ports + default adapters (fakes unless Umeng/Firebase configured).
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

    final umengConfig = UmengConfig.fromEnvironment();
    Get.put<UmengConfig>(umengConfig, permanent: true);
    Get.put<UmengBootstrap>(
      UmengBootstrap(config: umengConfig),
      permanent: true,
    );
    Get.put<StoreReviewConfig>(
      StoreReviewConfig.fromEnvironment(),
      permanent: true,
    );

    Get.put<Analytics>(FakeAnalytics(), permanent: true);
    Get.put<RemoteConfig>(
      FakeRemoteConfig({
        'demo_flag': true,
        'jank_monitor_enabled': true,
        'diagnostics_entry_enabled': false,
      }),
      permanent: true,
    );
    Get.put<CrashReporter>(FakeCrashReporter(), permanent: true);
    Get.put<AppLogger>(
      ConsoleAppLogger(crashReporter: Get.find<CrashReporter>()),
      permanent: true,
    );
    Get.put<AppEvents>(AppEvents(Get.find<Analytics>()), permanent: true);
    Get.put<JankMonitor>(
      JankMonitor(
        appEvents: Get.find<AppEvents>(),
        remoteConfig: Get.find<RemoteConfig>(),
      ),
      permanent: true,
    );
    Get.put<DiagnosticsAccess>(
      DiagnosticsAccess(
        environment: env,
        remoteConfig: Get.find<RemoteConfig>(),
      ),
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

  /// Prefer Umeng when keys allow init; otherwise fall back to Firebase wiring.
  static Future<void> wireAnalyticsAdapters({bool forceFakeOps = false}) async {
    if (forceFakeOps) return;

    final umengOk = await Get.find<UmengBootstrap>().tryInit(
      environment: Get.find<AppEnvironment>(),
      store: Get.find<KeyValueStore>(),
    );
    if (umengOk) {
      _replaceAnalyticsOnly(UmengAnalyticsAdapter());
      return;
    }

    await wireFirebaseAdapters(forceFakeOps: forceFakeOps);
  }

  /// Call after the instance privacy UI obtains consent (prod Umeng path).
  static Future<bool> enableUmengAfterPrivacyConsent() async {
    await PrivacyConsent.accept(Get.find<KeyValueStore>());
    final ok = await Get.find<UmengBootstrap>().tryInit(
      environment: Get.find<AppEnvironment>(),
      store: Get.find<KeyValueStore>(),
    );
    if (!ok) return false;
    _replaceAnalyticsOnly(UmengAnalyticsAdapter());
    return true;
  }

  static void _replaceAnalyticsOnly(Analytics analytics) {
    Get
      ..delete<Analytics>(force: true)
      ..delete<AppEvents>(force: true)
      ..delete<JankMonitor>(force: true);
    Get.put<Analytics>(analytics, permanent: true);
    Get.put<AppEvents>(AppEvents(Get.find<Analytics>()), permanent: true);
    Get.put<JankMonitor>(
      JankMonitor(
        appEvents: Get.find<AppEvents>(),
        remoteConfig: Get.find<RemoteConfig>(),
      ),
      permanent: true,
    );
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
      ..delete<AppLogger>(force: true)
      ..delete<AppEvents>(force: true)
      ..delete<JankMonitor>(force: true)
      ..delete<DiagnosticsAccess>(force: true);
    Get.put<Analytics>(FirebaseAnalyticsAdapter(), permanent: true);
    Get.put<RemoteConfig>(FirebaseRemoteConfigAdapter(), permanent: true);
    Get.put<CrashReporter>(FirebaseCrashlyticsAdapter(), permanent: true);
    Get.put<AppLogger>(
      ConsoleAppLogger(crashReporter: Get.find<CrashReporter>()),
      permanent: true,
    );
    Get.put<AppEvents>(AppEvents(Get.find<Analytics>()), permanent: true);
    Get.put<JankMonitor>(
      JankMonitor(
        appEvents: Get.find<AppEvents>(),
        remoteConfig: Get.find<RemoteConfig>(),
      ),
      permanent: true,
    );
    Get.put<DiagnosticsAccess>(
      DiagnosticsAccess(
        environment: Get.find<AppEnvironment>(),
        remoteConfig: Get.find<RemoteConfig>(),
      ),
      permanent: true,
    );
  }
}
