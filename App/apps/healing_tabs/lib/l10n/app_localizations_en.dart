// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Home';

  @override
  String get homeHello => 'Hello World!';

  @override
  String homeVariant(String variant) {
    return 'Build variant: $variant';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLogEvent => 'Log analytics event';

  @override
  String get settingsFeatureFlag => 'Feature flag: demo_flag';

  @override
  String get settingsTestCrash => 'Trigger test error (dev only)';

  @override
  String get settingsHeartbeat => 'Send ops console heartbeat';

  @override
  String get settingsLastEvent => 'Last event';
}
