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
  String get homeOpenCatalog => 'Open catalog';

  @override
  String get homeOpenSettings => 'Open settings';

  @override
  String get homeDiagnosticsHint =>
      'Tap the title 7× to open diagnostics (prod secret entry).';

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

  @override
  String get catalogTitle => 'Capability catalog';

  @override
  String get catalogIntro =>
      'Interactive demos of App* controls, motion, analytics, and jank monitoring.';

  @override
  String get catalogSectionSplash => 'Splash & Onboarding';

  @override
  String get catalogPreviewSplash => 'Preview splash';

  @override
  String get catalogPreviewOnboarding => 'Preview onboarding';

  @override
  String get catalogResetOnboarding => 'Reset onboarding flag';

  @override
  String get catalogResetOnboardingDone =>
      'Onboarding will show on next cold start';

  @override
  String get catalogSectionRating => 'Rating & feedback';

  @override
  String get catalogShowRating => 'Show rating prompt';

  @override
  String get catalogShowRatingHint =>
      'Good → store, bad → feedback, later → dismiss';

  @override
  String get catalogOpenFeedback => 'Open feedback form';

  @override
  String get ratingTitle => 'Rate us';

  @override
  String get ratingMessage =>
      'Your encouragement helps more people discover this app.';

  @override
  String get ratingPositive => 'Looks good! Encourage us';

  @override
  String get ratingNegative => 'Can\'t stand it — complain';

  @override
  String get ratingLater => 'Maybe later';

  @override
  String get ratingStoreUrlMissing =>
      'Store URL not configured (set store.* in instance.config.yaml)';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHint =>
      'Tell us what went wrong. We log a submit event only — message body stays on device.';

  @override
  String get feedbackMessageLabel => 'Your feedback';

  @override
  String get feedbackMessageHint => 'What should we improve?';

  @override
  String get feedbackSubmit => 'Submit';

  @override
  String get feedbackSubmitted => 'Thanks — feedback recorded';

  @override
  String get splashInitializing => 'Initializing…';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSlide1Title => 'A solid foundation';

  @override
  String get onboardingSlide1Body =>
      'Brand splash, flavors, and ops ports so you can ship the first build faster.';

  @override
  String get onboardingSlide2Title => 'Reusable App* controls';

  @override
  String get onboardingSlide2Body =>
      'Buttons, dialogs, toasts, skeletons, and transitions live under core/ui.';

  @override
  String get onboardingSlide3Title => 'Ops you can see';

  @override
  String get onboardingSlide3Body =>
      'Typed analytics, jank sampling, and a diagnostics entry for healthy releases.';

  @override
  String get onboardingSlide4Title => 'Make it yours';

  @override
  String get onboardingSlide4Body =>
      'Swap logo, slogan, copyright, and bump onboarding_version after a major update.';

  @override
  String get catalogSectionButtons => 'Buttons';

  @override
  String get catalogButtonsHint => 'AppButton variants plus a loading state.';

  @override
  String get catalogSectionDialogs => 'Dialogs';

  @override
  String get catalogDialogConfirm => 'Confirm dialog';

  @override
  String get catalogDialogAlert => 'Alert dialog';

  @override
  String get catalogSectionFeedback => 'Feedback';

  @override
  String get catalogFeedbackOverlay => 'Loading overlay';

  @override
  String get catalogSectionPlaceholders => 'Placeholders';

  @override
  String get catalogEmptyTitle => 'Nothing here';

  @override
  String get catalogEmptyDescription =>
      'AppEmpty placeholder used for empty states.';

  @override
  String get catalogSectionMotion => 'Motion';

  @override
  String get catalogMotionAppearHint =>
      'AppAppear wraps this card. Push a route to preview page transitions.';

  @override
  String get catalogMotionSharedAxis => 'Shared axis transition';

  @override
  String get catalogMotionFadeThrough => 'Fade through transition';

  @override
  String get catalogMotionFadeScale => 'Fade scale transition';

  @override
  String get catalogSectionLoadingMotion => 'Loading views';

  @override
  String get catalogMotionLoadingHint =>
      'Spinners, linear progress, and a skeleton-to-content fade-through.';

  @override
  String get catalogMotionRunProgress => 'Run progress';

  @override
  String get catalogMotionReveal => 'Toggle content';

  @override
  String get catalogMotionLoadedContent =>
      'Content ready. This block replaced the skeleton.';

  @override
  String get catalogSectionPullRefresh => 'Pull to refresh';

  @override
  String get catalogMotionPullRefresh => 'Open pull-to-refresh page';

  @override
  String get catalogMotionPullRefreshHint =>
      'Full-screen list you can drag down.';

  @override
  String get catalogRefreshTitle => 'Pull to refresh';

  @override
  String get catalogRefreshHint =>
      'Drag down to add a row. Spinner is FCircularProgress.loader.';

  @override
  String catalogRefreshItem(int index) {
    return 'Item $index';
  }

  @override
  String get catalogSectionAccordion => 'Accordion';

  @override
  String get catalogAccordionHint =>
      'FAccordion animates height and the chevron.';

  @override
  String get catalogAccordionItem1 => 'What is this?';

  @override
  String get catalogAccordionBody1 =>
      'A stacked heading that reveals extra copy when expanded.';

  @override
  String get catalogAccordionItem2 => 'When to use it?';

  @override
  String get catalogAccordionBody2 =>
      'FAQ rows, grouped settings, or any list that hides detail.';

  @override
  String get catalogAccordionItem3 => 'How is it animated?';

  @override
  String get catalogAccordionBody3 =>
      'Forui drives a height clip plus icon rotation.';

  @override
  String get catalogSectionUpdatePrompt => 'Update prompt';

  @override
  String get catalogUpdateShowSheet => 'Show sheet';

  @override
  String get catalogUpdateShowBanner => 'Show banner';

  @override
  String get catalogUpdateDismissBanner => 'Dismiss banner';

  @override
  String get catalogUpdateTitle => 'Update available';

  @override
  String get catalogUpdateVersion => 'Version 1.2.0';

  @override
  String get catalogUpdateNotes => 'Bug fixes and a smoother catalog demo.';

  @override
  String get catalogUpdateAction => 'Update';

  @override
  String get catalogUpdateLater => 'Later';

  @override
  String get catalogUpdateStarted => 'Update started';

  @override
  String get catalogUpdateBannerTitle => 'A new version is ready';

  @override
  String get catalogUpdateBannerSubtitle =>
      'Tap the sheet button to preview the slide-up prompt.';

  @override
  String get catalogSectionAnalytics => 'Analytics';

  @override
  String get catalogAnalyticsBackend => 'Analytics backend';

  @override
  String get catalogAnalyticsFire => 'Fire catalog demo event';

  @override
  String get catalogAnalyticsLast => 'Last event';

  @override
  String get catalogSectionMonitoring => 'Monitoring';

  @override
  String get catalogMonitoringJankCount => 'Recent jank count';

  @override
  String get catalogMonitoringSimulate => 'Simulate jank';

  @override
  String get catalogMonitoringDiagnostics => 'Open diagnostics';

  @override
  String get catalogSectionMotionAssets => 'Lottie / Rive';

  @override
  String get catalogMotionAssetsTitle => 'Add assets in your instance';

  @override
  String get catalogMotionAssetsDescription =>
      'Use AppLottie.asset / AppRive.asset after adding files. Sample assets are not shipped in the template (ADR 0005).';
}
