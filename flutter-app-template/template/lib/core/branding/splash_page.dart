import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/ops/app_events.dart';
import '../../core/storage/key_value_store.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';
import 'branding_config.dart';
import 'onboarding_gate.dart';
import 'splash_branding_view.dart';

/// Flutter **启动品牌页**: cold-start only, min display duration from [BrandingConfig].
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Process-lifetime flag: after first dismiss, skip on subsequent route entries.
  static bool coldStartCompleted = false;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    if (SplashPage.coldStartCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.home);
      });
      return;
    }

    final branding = BrandingConfig.fromEnvironment();
    final minMs = branding.splashMinMs < 0 ? 0 : branding.splashMinMs;
    final started = DateTime.now();

    try {
      if (Get.isRegistered<AppEvents>()) {
        await Get.find<AppEvents>().appOpen();
      }
    } catch (_) {
      // ignore analytics failures on splash
    }

    final elapsed = DateTime.now().difference(started).inMilliseconds;
    final wait = minMs - elapsed;
    if (wait > 0) {
      await Future<void>.delayed(Duration(milliseconds: wait));
    }

    SplashPage.coldStartCompleted = true;
    if (!mounted) return;

    final next = await _nextRoute(branding);
    if (!mounted) return;
    Get.offAllNamed(next);
  }

  Future<String> _nextRoute(BrandingConfig branding) async {
    if (!Get.isRegistered<KeyValueStore>()) {
      return AppRoutes.home;
    }
    final store = Get.find<KeyValueStore>();
    final show = await OnboardingGate.shouldShow(
      store,
      branding.onboardingVersion,
    );
    return show ? AppRoutes.onboarding : AppRoutes.home;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branding = BrandingConfig.fromEnvironment();

    return FScaffold(
      child: SplashBrandingView(
        branding: branding,
        initializingLabel: l10n.splashInitializing,
        showLoading: true,
      ),
    );
  }
}
