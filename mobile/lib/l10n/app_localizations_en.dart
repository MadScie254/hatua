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
      'Private goals and tracked applications are encrypted on Android, stay on this device and are excluded from backups. Public directory copies last up to 24 hours. No medical history is collected.';

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
      'Remove private goals, tracked applications, saved listings and preferences.';

  @override
  String get settingsDeleteConfirmTitle => 'Delete local data?';

  @override
  String get settingsDeleteConfirmBody =>
      'This permanently removes goals, tracked applications, saved listings, preferences and cached public data.';

  @override
  String get settingsDeleted => 'Local app data cleared.';

  @override
  String get settingsDeleteFailed => 'Could not clear all data. Please retry.';

  @override
  String get settingsVersion => 'HATUA v0.2.0, pilot preview';

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
      'This deletes your private goals and tracked applications together.';

  @override
  String get reset => 'Reset';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get planUnsupportedTitle => 'My Plan works in the Android app';

  @override
  String get planUnsupportedBody =>
      'Private goals and application tracking need Android secure storage. This web version does not store either. Other features still work here.';

  @override
  String get settingsPrivacyBodyNoGoals =>
      'This web version does not store goals or application tracking. Saved listings, your county and language are kept in this browser, alongside public directory data for up to 24 hours. Nothing is uploaded and no medical history is collected.';

  @override
  String get exploreTrack => 'Track application';

  @override
  String get exploreTracked => 'Tracked in My Plan';

  @override
  String get exploreTrackAdded => 'Added to My Plan.';

  @override
  String get exploreTrackAndroidOnly =>
      'Private tracking requires secure storage on Android.';

  @override
  String get planApplicationsTitle => 'My applications';

  @override
  String get planApplicationsIntro =>
      'Track progress privately. Opening a link is not an application.';

  @override
  String get planApplicationsEmpty =>
      'Nothing tracked yet. Add a listing from Explore.';

  @override
  String get planApplicationStatus => 'Application progress';

  @override
  String get planApplicationRemove => 'Remove application';

  @override
  String get applicationStageInterested => 'Interested';

  @override
  String get applicationStageApplied => 'Applied';

  @override
  String get applicationStageInterview => 'Interview';

  @override
  String get applicationStageOffered => 'Offer received';

  @override
  String get applicationStageClosed => 'Closed';

  @override
  String get homeTalkNowTitle => 'Talk to someone now';

  @override
  String get homeTalkNowBody =>
      'Free NACADA helpline for alcohol and drug use, open 24 hours. Not an ambulance service.';

  @override
  String get homeCall1192 => 'Call 1192';

  @override
  String get homeCountyChoose => 'Choose your county';

  @override
  String homeCountySelected(String county) {
    return 'Showing $county first';
  }

  @override
  String get changeCounty => 'Change';

  @override
  String get detailsButton => 'Details';

  @override
  String get detailAbout => 'About';

  @override
  String get detailWhoCanApply => 'Who can apply';

  @override
  String get detailCost => 'Cost';

  @override
  String get detailHowToApply => 'How to apply';

  @override
  String get detailNoApplyLink =>
      'There is no online form. Use the contacts in the description above.';

  @override
  String get deadlineNone => 'No closing date listed';

  @override
  String deadlineIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Closes in $days days',
      one: 'Closes tomorrow',
      zero: 'Closes today',
    );
    return '$_temp0';
  }

  @override
  String get copyToShare => 'Copy to share';

  @override
  String get copiedToShare => 'Copied. Paste it into a message to share it.';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportTitle => 'What is wrong with this listing?';

  @override
  String get reportReasonBrokenLink => 'The link does not work';

  @override
  String get reportReasonWrongContact => 'The phone number or address is wrong';

  @override
  String get reportReasonClosed => 'It is closed, full or no longer offered';

  @override
  String get reportReasonScam => 'It looks like a scam or asks for money';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportNoteLabel => 'Details (optional)';

  @override
  String get reportNoteHint => 'Do not include your name or phone number.';

  @override
  String get reportPrivacy =>
      'Reports are anonymous. HATUA does not record who sent them.';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSent => 'Report sent. HATUA staff will check this listing.';

  @override
  String get reportFailed =>
      'Could not send the report. Check your connection and try again.';

  @override
  String get supportHelplinesTitle => 'Helplines you can call now';

  @override
  String get supportNearTitle => 'Treatment and support near you';

  @override
  String get supportNearChooseCounty =>
      'Choose your county to see NACADA-accredited centres near you first.';

  @override
  String supportNoneInCounty(String county) {
    return 'No listed centres in $county yet. Services in other counties are below.';
  }

  @override
  String get supportOtherCounties => 'Other counties';

  @override
  String get supportMoreHelp => 'More help and information';

  @override
  String get supportCopyNumber => 'Copy number';

  @override
  String get numberCopied => 'Number copied';

  @override
  String get supportDirections => 'Directions';

  @override
  String get supportCallBefore =>
      'Call before you travel to confirm opening hours, services and fees.';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get welcomeLanguage => 'Choose your language';

  @override
  String get welcomePrivacyTitle => 'Private by design';

  @override
  String get welcomeNoAccount =>
      'No account and no tracking. Use everything as a guest.';

  @override
  String get welcomeOnDevice =>
      'Your county and saved listings stay on this device.';

  @override
  String get welcomeSupportPrivate =>
      'Support services you look at are never saved.';

  @override
  String get welcomeCounty => 'Your county (optional)';

  @override
  String get welcomeStart => 'Start';
}
