import 'package:flutter/widgets.dart';

import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

List<OnboardingSlide> onboardingSlidesFor(AppLocalizations l10n) => [
      OnboardingSlide(
        title: l10n.onboardingSlide1Title,
        body: l10n.onboardingSlide1Body,
        icon: FLucideIcons.box,
      ),
      OnboardingSlide(
        title: l10n.onboardingSlide2Title,
        body: l10n.onboardingSlide2Body,
        icon: FLucideIcons.layers,
      ),
      OnboardingSlide(
        title: l10n.onboardingSlide3Title,
        body: l10n.onboardingSlide3Body,
        icon: FLucideIcons.activity,
      ),
      OnboardingSlide(
        title: l10n.onboardingSlide4Title,
        body: l10n.onboardingSlide4Body,
        icon: FLucideIcons.rocket,
      ),
    ];
