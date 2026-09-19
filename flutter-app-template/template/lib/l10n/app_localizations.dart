import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get homeHello;

  /// No description provided for @homeVariant.
  ///
  /// In en, this message translates to:
  /// **'Build variant: {variant}'**
  String homeVariant(String variant);

  /// No description provided for @homeOpenCatalog.
  ///
  /// In en, this message translates to:
  /// **'Open catalog'**
  String get homeOpenCatalog;

  /// No description provided for @homeOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get homeOpenSettings;

  /// No description provided for @homeDiagnosticsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the title 7× to open diagnostics (prod secret entry).'**
  String get homeDiagnosticsHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLogEvent.
  ///
  /// In en, this message translates to:
  /// **'Log analytics event'**
  String get settingsLogEvent;

  /// No description provided for @settingsFeatureFlag.
  ///
  /// In en, this message translates to:
  /// **'Feature flag: demo_flag'**
  String get settingsFeatureFlag;

  /// No description provided for @settingsTestCrash.
  ///
  /// In en, this message translates to:
  /// **'Trigger test error (dev only)'**
  String get settingsTestCrash;

  /// No description provided for @settingsHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Send ops console heartbeat'**
  String get settingsHeartbeat;

  /// No description provided for @settingsLastEvent.
  ///
  /// In en, this message translates to:
  /// **'Last event'**
  String get settingsLastEvent;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Capability catalog'**
  String get catalogTitle;

  /// No description provided for @catalogIntro.
  ///
  /// In en, this message translates to:
  /// **'Interactive demos of App* controls, motion, analytics, and jank monitoring.'**
  String get catalogIntro;

  /// No description provided for @catalogSectionSplash.
  ///
  /// In en, this message translates to:
  /// **'Splash & Onboarding'**
  String get catalogSectionSplash;

  /// No description provided for @catalogPreviewSplash.
  ///
  /// In en, this message translates to:
  /// **'Preview splash'**
  String get catalogPreviewSplash;

  /// No description provided for @catalogPreviewOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Preview onboarding'**
  String get catalogPreviewOnboarding;

  /// No description provided for @catalogResetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding flag'**
  String get catalogResetOnboarding;

  /// No description provided for @catalogResetOnboardingDone.
  ///
  /// In en, this message translates to:
  /// **'Onboarding will show on next cold start'**
  String get catalogResetOnboardingDone;

  /// No description provided for @catalogSectionRating.
  ///
  /// In en, this message translates to:
  /// **'Rating & feedback'**
  String get catalogSectionRating;

  /// No description provided for @catalogShowRating.
  ///
  /// In en, this message translates to:
  /// **'Show rating prompt'**
  String get catalogShowRating;

  /// No description provided for @catalogShowRatingHint.
  ///
  /// In en, this message translates to:
  /// **'Good → store, bad → feedback, later → dismiss'**
  String get catalogShowRatingHint;

  /// No description provided for @catalogOpenFeedback.
  ///
  /// In en, this message translates to:
  /// **'Open feedback form'**
  String get catalogOpenFeedback;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get ratingTitle;

  /// No description provided for @ratingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your encouragement helps more people discover this app.'**
  String get ratingMessage;

  /// No description provided for @ratingPositive.
  ///
  /// In en, this message translates to:
  /// **'Looks good! Encourage us'**
  String get ratingPositive;

  /// No description provided for @ratingNegative.
  ///
  /// In en, this message translates to:
  /// **'Can\'t stand it — complain'**
  String get ratingNegative;

  /// No description provided for @ratingLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get ratingLater;

  /// No description provided for @ratingStoreUrlMissing.
  ///
  /// In en, this message translates to:
  /// **'Store URL not configured (set store.* in instance.config.yaml)'**
  String get ratingStoreUrlMissing;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong. We log a submit event only — message body stays on device.'**
  String get feedbackHint;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What should we improve?'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks — feedback recorded'**
  String get feedbackSubmitted;

  /// No description provided for @splashInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing…'**
  String get splashInitializing;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'A solid foundation'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Brand splash, flavors, and ops ports so you can ship the first build faster.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Reusable App* controls'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Buttons, dialogs, toasts, skeletons, and transitions live under core/ui.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Ops you can see'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Typed analytics, jank sampling, and a diagnostics entry for healthy releases.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Body.
  ///
  /// In en, this message translates to:
  /// **'Swap logo, slogan, copyright, and bump onboarding_version after a major update.'**
  String get onboardingSlide4Body;

  /// No description provided for @catalogSectionButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get catalogSectionButtons;

  /// No description provided for @catalogButtonsHint.
  ///
  /// In en, this message translates to:
  /// **'AppButton variants plus a loading state.'**
  String get catalogButtonsHint;

  /// No description provided for @catalogSectionDialogs.
  ///
  /// In en, this message translates to:
  /// **'Dialogs'**
  String get catalogSectionDialogs;

  /// No description provided for @catalogDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm dialog'**
  String get catalogDialogConfirm;

  /// No description provided for @catalogDialogAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert dialog'**
  String get catalogDialogAlert;

  /// No description provided for @catalogSectionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get catalogSectionFeedback;

  /// No description provided for @catalogFeedbackOverlay.
  ///
  /// In en, this message translates to:
  /// **'Loading overlay'**
  String get catalogFeedbackOverlay;

  /// No description provided for @catalogSectionPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Placeholders'**
  String get catalogSectionPlaceholders;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'AppEmpty placeholder used for empty states.'**
  String get catalogEmptyDescription;

  /// No description provided for @catalogSectionMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get catalogSectionMotion;

  /// No description provided for @catalogMotionAppearHint.
  ///
  /// In en, this message translates to:
  /// **'AppAppear wraps this card. Push a route to preview page transitions.'**
  String get catalogMotionAppearHint;

  /// No description provided for @catalogMotionSharedAxis.
  ///
  /// In en, this message translates to:
  /// **'Shared axis transition'**
  String get catalogMotionSharedAxis;

  /// No description provided for @catalogMotionFadeThrough.
  ///
  /// In en, this message translates to:
  /// **'Fade through transition'**
  String get catalogMotionFadeThrough;

  /// No description provided for @catalogMotionFadeScale.
  ///
  /// In en, this message translates to:
  /// **'Fade scale transition'**
  String get catalogMotionFadeScale;

  /// No description provided for @catalogSectionLoadingMotion.
  ///
  /// In en, this message translates to:
  /// **'Loading views'**
  String get catalogSectionLoadingMotion;

  /// No description provided for @catalogMotionLoadingHint.
  ///
  /// In en, this message translates to:
  /// **'Spinners, linear progress, and a skeleton-to-content fade-through.'**
  String get catalogMotionLoadingHint;

  /// No description provided for @catalogMotionRunProgress.
  ///
  /// In en, this message translates to:
  /// **'Run progress'**
  String get catalogMotionRunProgress;

  /// No description provided for @catalogMotionReveal.
  ///
  /// In en, this message translates to:
  /// **'Toggle content'**
  String get catalogMotionReveal;

  /// No description provided for @catalogMotionLoadedContent.
  ///
  /// In en, this message translates to:
  /// **'Content ready. This block replaced the skeleton.'**
  String get catalogMotionLoadedContent;

  /// No description provided for @catalogSectionPullRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get catalogSectionPullRefresh;

  /// No description provided for @catalogMotionPullRefresh.
  ///
  /// In en, this message translates to:
  /// **'Open pull-to-refresh page'**
  String get catalogMotionPullRefresh;

  /// No description provided for @catalogMotionPullRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Full-screen list you can drag down.'**
  String get catalogMotionPullRefreshHint;

  /// No description provided for @catalogRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get catalogRefreshTitle;

  /// No description provided for @catalogRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Drag down to add a row. Spinner is FCircularProgress.loader.'**
  String get catalogRefreshHint;

  /// No description provided for @catalogRefreshItem.
  ///
  /// In en, this message translates to:
  /// **'Item {index}'**
  String catalogRefreshItem(int index);

  /// No description provided for @catalogSectionAccordion.
  ///
  /// In en, this message translates to:
  /// **'Accordion'**
  String get catalogSectionAccordion;

  /// No description provided for @catalogAccordionHint.
  ///
  /// In en, this message translates to:
  /// **'FAccordion animates height and the chevron.'**
  String get catalogAccordionHint;

  /// No description provided for @catalogAccordionItem1.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get catalogAccordionItem1;

  /// No description provided for @catalogAccordionBody1.
  ///
  /// In en, this message translates to:
  /// **'A stacked heading that reveals extra copy when expanded.'**
  String get catalogAccordionBody1;

  /// No description provided for @catalogAccordionItem2.
  ///
  /// In en, this message translates to:
  /// **'When to use it?'**
  String get catalogAccordionItem2;

  /// No description provided for @catalogAccordionBody2.
  ///
  /// In en, this message translates to:
  /// **'FAQ rows, grouped settings, or any list that hides detail.'**
  String get catalogAccordionBody2;

  /// No description provided for @catalogAccordionItem3.
  ///
  /// In en, this message translates to:
  /// **'How is it animated?'**
  String get catalogAccordionItem3;

  /// No description provided for @catalogAccordionBody3.
  ///
  /// In en, this message translates to:
  /// **'Forui drives a height clip plus icon rotation.'**
  String get catalogAccordionBody3;

  /// No description provided for @catalogSectionUpdatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Update prompt'**
  String get catalogSectionUpdatePrompt;

  /// No description provided for @catalogUpdateShowSheet.
  ///
  /// In en, this message translates to:
  /// **'Show sheet'**
  String get catalogUpdateShowSheet;

  /// No description provided for @catalogUpdateShowBanner.
  ///
  /// In en, this message translates to:
  /// **'Show banner'**
  String get catalogUpdateShowBanner;

  /// No description provided for @catalogUpdateDismissBanner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss banner'**
  String get catalogUpdateDismissBanner;

  /// No description provided for @catalogUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get catalogUpdateTitle;

  /// No description provided for @catalogUpdateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.2.0'**
  String get catalogUpdateVersion;

  /// No description provided for @catalogUpdateNotes.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes and a smoother catalog demo.'**
  String get catalogUpdateNotes;

  /// No description provided for @catalogUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get catalogUpdateAction;

  /// No description provided for @catalogUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get catalogUpdateLater;

  /// No description provided for @catalogUpdateStarted.
  ///
  /// In en, this message translates to:
  /// **'Update started'**
  String get catalogUpdateStarted;

  /// No description provided for @catalogUpdateBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'A new version is ready'**
  String get catalogUpdateBannerTitle;

  /// No description provided for @catalogUpdateBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the sheet button to preview the slide-up prompt.'**
  String get catalogUpdateBannerSubtitle;

  /// No description provided for @catalogSectionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get catalogSectionAnalytics;

  /// No description provided for @catalogAnalyticsBackend.
  ///
  /// In en, this message translates to:
  /// **'Analytics backend'**
  String get catalogAnalyticsBackend;

  /// No description provided for @catalogAnalyticsFire.
  ///
  /// In en, this message translates to:
  /// **'Fire catalog demo event'**
  String get catalogAnalyticsFire;

  /// No description provided for @catalogAnalyticsLast.
  ///
  /// In en, this message translates to:
  /// **'Last event'**
  String get catalogAnalyticsLast;

  /// No description provided for @catalogSectionMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get catalogSectionMonitoring;

  /// No description provided for @catalogMonitoringJankCount.
  ///
  /// In en, this message translates to:
  /// **'Recent jank count'**
  String get catalogMonitoringJankCount;

  /// No description provided for @catalogMonitoringSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate jank'**
  String get catalogMonitoringSimulate;

  /// No description provided for @catalogMonitoringDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Open diagnostics'**
  String get catalogMonitoringDiagnostics;

  /// No description provided for @catalogSectionMotionAssets.
  ///
  /// In en, this message translates to:
  /// **'Lottie / Rive'**
  String get catalogSectionMotionAssets;

  /// No description provided for @catalogMotionAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add assets in your instance'**
  String get catalogMotionAssetsTitle;

  /// No description provided for @catalogMotionAssetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Use AppLottie.asset / AppRive.asset after adding files. Sample assets are not shipped in the template (ADR 0005).'**
  String get catalogMotionAssetsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
