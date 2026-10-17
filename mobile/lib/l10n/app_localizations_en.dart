// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HATUA';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navSupport => 'Support';

  @override
  String get navPlan => 'My Plan';

  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get storageErrorMessage =>
      'Secure local storage could not be opened. Please retry.';

  @override
  String get storageResetAction => 'Delete local data and continue';

  @override
  String get homeGreeting => 'Karibu HATUA';

  @override
  String get homeTagline => 'One step forward, every day.';

  @override
  String get homeQuestion => 'What would help you today?';

  @override
  String get homeIntro =>
      'Explore opportunities, get confidential support information, or plan a small next step.';

  @override
  String get homeFindOpportunities => 'Find opportunities';

  @override
  String get homeFindOpportunitiesSubtitle =>
      'Verified jobs, training and community programmes';

  @override
  String get homeFindSupport => 'Find support';

  @override
  String get homeFindSupportSubtitle =>
      'Trusted support resources and confidential helplines';

  @override
  String get homeNextSteps => 'My next steps';

  @override
  String get homeNextStepsSubtitle =>
      'Keep track of goals privately on your device';

  @override
  String get homeGuestNote =>
      'Browse freely. No account or personal history required.';

  @override
  String get filterCounty => 'County';

  @override
  String get filterAllCounties => 'All counties';

  @override
  String get countyNationwide => 'Nationwide';

  @override
  String get filterAll => 'All';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get statusCachedTitle => 'Offline or server unavailable';

  @override
  String statusCachedOpportunities(String when) {
    return 'Showing public listings saved $when. Check deadlines again when you are online.';
  }

  @override
  String statusCachedSupport(String when) {
    return 'Showing contacts saved $when. Numbers and opening hours may have changed.';
  }

  @override
  String get statusUnavailableTitle => 'Couldn\'t load the directory';

  @override
  String get statusUnavailableBody =>
      'Check your connection and try again. Saved copies are deleted after 24 hours.';

  @override
  String get exploreTitle => 'Explore opportunities';

  @override
  String get exploreIntro =>
      'Public listings are reviewed before publication. Always verify details with the original source.';

  @override
  String get exploreSearchHint => 'Search jobs, training, organisations';

  @override
  String get exploreSavedOnly => 'Saved only';

  @override
  String get exploreEmpty =>
      'No verified opportunities to show yet. Pull down to refresh when connected.';

  @override
  String get exploreNoMatches =>
      'No verified opportunities match these filters.';

  @override
  String get saveOpportunity => 'Save opportunity';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String opportunityCloses(String date) {
    return 'Closes $date';
  }

  @override
  String opportunityCost(String cost) {
    return 'Cost: $cost';
  }

  @override
  String opportunityEligibility(String text) {
    return 'Eligibility: $text';
  }

  @override
  String lastChecked(String date) {
    return 'Last checked by HATUA on $date';
  }

  @override
  String get applyAtSource => 'Apply at source';

  @override
  String get verifySource => 'Verify source';

  @override
  String get linkOpenFailed => 'Unable to open this link.';

  @override
  String get categoryJob => 'Employment';

  @override
  String get categoryTraining => 'Training';

  @override
  String get categoryGrant => 'Grant / financial assistance';

  @override
  String get categoryApprenticeship => 'Apprenticeship';

  @override
  String get categoryOther => 'Other';

  @override
  String get supportTitle => 'Find support';

  @override
  String get supportIntro =>
      'Seeking help is a personal choice. Browse without signing in or sharing your history.';

  @override
  String get supportTalkTitle => 'Talk to someone';

  @override
  String get supportNacadaBody =>
      'NACADA offers alcohol and substance-use support in Kenya via 1192. Not an emergency ambulance service.';

  @override
  String get supportCall1192 => 'Open dialer: 1192';

  @override
  String get supportEmergencyTitle => 'In an emergency';

  @override
  String get supportEmergencyBody =>
      'If someone is unconscious, having seizures, struggling to breathe, or experiencing severe withdrawal, seek emergency medical care immediately. This app does not diagnose or treat conditions.';

  @override
  String get supportSearchHint => 'Search resources';

  @override
  String get supportEmpty =>
      'No additional verified resources available yet. You can still use the 1192 contact above.';

  @override
  String get supportNoMatches =>
      'No verified resources match these filters. You can still use the 1192 contact above.';

  @override
  String get supportCall => 'Call';

  @override
  String get supportWebsite => 'Website';

  @override
  String get contactOpenFailed => 'Unable to open this contact.';

  @override
  String get kindHelpline => 'Helpline';

  @override
  String get kindFacility => 'Treatment facility';

  @override
  String get kindNgo => 'Support organisation';

  @override
  String get kindEducation => 'Education resource';

  @override
  String get planTitle => 'My next steps';

  @override
  String get planIntro =>
      'Make room for small, achievable goals. They stay on this device in encrypted storage and are never uploaded.';

  @override
  String get planInputLabel => 'One step I want to take';

  @override
  String get planInputHint => 'e.g. Prepare my CV';

  @override
  String get planAdd => 'Add goal';

  @override
  String planProgress(int done, int total) {
    return '$done of $total completed';
  }

  @override
  String get planEmpty =>
      'No goals yet. Start with something small and important to you.';

  @override
  String get planDelete => 'Delete goal';

  @override
  String get planSaveFailed => 'Could not save securely. Please try again.';

  @override
  String get planUpdateFailed => 'Unable to update goal.';

  @override
  String get planDeleteFailed => 'Unable to delete goal.';

  @override
  String get settingsTitle => 'Settings & privacy';

  @override
  String get settingsGuestTitle => 'Guest mode';

  @override
  String get settingsGuestBody =>
      'No account required. This version does not create or upload a personal profile.';

  @override
  String get settingsPrivacyTitle => 'Privacy by design';

  @override
  String get settingsPrivacyBody =>
      'Goals are stored in encrypted device storage and excluded from backups. Public directory data may be kept for up to 24 hours for offline use. No medical history is collected.';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSwahili => 'Kiswahili';

  @override
  String get settingsSwahiliDraftNote =>
      'The Kiswahili translation is a draft and is still being reviewed.';

  @override
  String get settingsDeleteTitle => 'Delete my local data';

  @override
  String get settingsDeleteBody =>
      'Remove saved listings, goals, preferences and cached directories.';

  @override
  String get settingsDeleteConfirmTitle => 'Delete local data?';

  @override
  String get settingsDeleteConfirmBody =>
      'This permanently removes goals, saved opportunities, preferences and cached public listings from this device.';

  @override
  String get settingsDeleted => 'Local app data cleared.';

  @override
  String get settingsDeleteFailed => 'Could not clear all data. Please retry.';

  @override
  String get settingsVersion => 'HATUA v0.1.1 · Development preview';

  @override
  String get settingsDisclaimer =>
      'HATUA is an information and referral tool, not a healthcare provider or a guarantee of employment.';

  @override
  String get planUnavailableTitle =>
      'Private goals are unavailable on this phone';

  @override
  String get planUnavailableBody =>
      'This phone\'s secure storage could not be used, so HATUA will not save goals rather than keep them unprotected. Everything else in the app still works.';

  @override
  String get planResetGoals => 'Reset private goals';

  @override
  String get planResetConfirmTitle => 'Reset private goals?';

  @override
  String get planResetConfirmBody =>
      'This deletes any saved goals and the key that protected them, then starts fresh.';

  @override
  String get reset => 'Reset';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get planUnsupportedTitle => 'My Plan works in the Android app';

  @override
  String get planUnsupportedBody =>
      'Private goals are encrypted with your phone\'s secure hardware. Browsers cannot offer that protection, so this web version does not store goals. Everything else works here.';

  @override
  String get settingsPrivacyBodyNoGoals =>
      'This web version does not store goals. Saved listings, your county and your language are kept in this browser only, and public directory data for up to 24 hours. Nothing is uploaded and no medical history is collected.';
}
