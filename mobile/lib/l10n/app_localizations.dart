import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HATUA'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get navSupport;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get navPlan;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @storageErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Secure local storage could not be opened. Please retry.'**
  String get storageErrorMessage;

  /// Shown when encrypted storage cannot be read at start-up. Deletes goals and local preferences so the app can open.
  ///
  /// In en, this message translates to:
  /// **'Delete local data and continue'**
  String get storageResetAction;

  /// Brand greeting; intentionally Kiswahili in both languages.
  ///
  /// In en, this message translates to:
  /// **'Karibu HATUA'**
  String get homeGreeting;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'One step forward, every day.'**
  String get homeTagline;

  /// No description provided for @homeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What would help you today?'**
  String get homeQuestion;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Explore opportunities, get confidential support information, or plan a small next step.'**
  String get homeIntro;

  /// No description provided for @homeFindOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Find opportunities'**
  String get homeFindOpportunities;

  /// No description provided for @homeFindOpportunitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified jobs, training and community programmes'**
  String get homeFindOpportunitiesSubtitle;

  /// No description provided for @homeFindSupport.
  ///
  /// In en, this message translates to:
  /// **'Find support'**
  String get homeFindSupport;

  /// No description provided for @homeFindSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted support resources and confidential helplines'**
  String get homeFindSupportSubtitle;

  /// No description provided for @homeNextSteps.
  ///
  /// In en, this message translates to:
  /// **'My next steps'**
  String get homeNextSteps;

  /// No description provided for @homeNextStepsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep track of goals privately on your device'**
  String get homeNextStepsSubtitle;

  /// No description provided for @homeGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Browse freely. No account or personal history required.'**
  String get homeGuestNote;

  /// No description provided for @filterCounty.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get filterCounty;

  /// No description provided for @filterAllCounties.
  ///
  /// In en, this message translates to:
  /// **'All counties'**
  String get filterAllCounties;

  /// Listing applies to the whole of Kenya.
  ///
  /// In en, this message translates to:
  /// **'Nationwide'**
  String get countyNationwide;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @statusCachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline or server unavailable'**
  String get statusCachedTitle;

  /// No description provided for @statusCachedOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Showing public listings saved {when}. Check deadlines again when you are online.'**
  String statusCachedOpportunities(String when);

  /// No description provided for @statusCachedSupport.
  ///
  /// In en, this message translates to:
  /// **'Showing contacts saved {when}. Numbers and opening hours may have changed.'**
  String statusCachedSupport(String when);

  /// No description provided for @statusUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the directory'**
  String get statusUnavailableTitle;

  /// No description provided for @statusUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again. Saved copies are deleted after 24 hours.'**
  String get statusUnavailableBody;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore opportunities'**
  String get exploreTitle;

  /// No description provided for @exploreIntro.
  ///
  /// In en, this message translates to:
  /// **'Public listings are reviewed before publication. Always verify details with the original source.'**
  String get exploreIntro;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search jobs, training, organisations'**
  String get exploreSearchHint;

  /// No description provided for @exploreSavedOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved only'**
  String get exploreSavedOnly;

  /// No description provided for @exploreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No verified opportunities to show yet. Pull down to refresh when connected.'**
  String get exploreEmpty;

  /// No description provided for @exploreNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No verified opportunities match these filters.'**
  String get exploreNoMatches;

  /// No description provided for @saveOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Save opportunity'**
  String get saveOpportunity;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @opportunityCloses.
  ///
  /// In en, this message translates to:
  /// **'Closes {date}'**
  String opportunityCloses(String date);

  /// No description provided for @opportunityCost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost}'**
  String opportunityCost(String cost);

  /// No description provided for @opportunityEligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility: {text}'**
  String opportunityEligibility(String text);

  /// When staff last verified the listing against its source.
  ///
  /// In en, this message translates to:
  /// **'Last checked by HATUA on {date}'**
  String lastChecked(String date);

  /// No description provided for @applyAtSource.
  ///
  /// In en, this message translates to:
  /// **'Apply at source'**
  String get applyAtSource;

  /// No description provided for @verifySource.
  ///
  /// In en, this message translates to:
  /// **'Verify source'**
  String get verifySource;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this link.'**
  String get linkOpenFailed;

  /// No description provided for @categoryJob.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get categoryJob;

  /// No description provided for @categoryTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get categoryTraining;

  /// No description provided for @categoryGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant / financial assistance'**
  String get categoryGrant;

  /// No description provided for @categoryApprenticeship.
  ///
  /// In en, this message translates to:
  /// **'Apprenticeship'**
  String get categoryApprenticeship;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Find support'**
  String get supportTitle;

  /// No description provided for @supportIntro.
  ///
  /// In en, this message translates to:
  /// **'Seeking help is a personal choice. Browse without signing in or sharing your history.'**
  String get supportIntro;

  /// No description provided for @supportTalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to someone'**
  String get supportTalkTitle;

  /// SAFETY COPY. Must keep: 1192 is NACADA's support line and is NOT an ambulance/emergency number.
  ///
  /// In en, this message translates to:
  /// **'NACADA offers alcohol and substance-use support in Kenya via 1192. Not an emergency ambulance service.'**
  String get supportNacadaBody;

  /// Opens the phone dialer pre-filled with 1192. It does not place the call.
  ///
  /// In en, this message translates to:
  /// **'Open dialer: 1192'**
  String get supportCall1192;

  /// No description provided for @supportEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'In an emergency'**
  String get supportEmergencyTitle;

  /// SAFETY COPY reviewed against docs/SAFETY_PRIVACY.md. Translation must be checked by a qualified professional.
  ///
  /// In en, this message translates to:
  /// **'If someone is unconscious, having seizures, struggling to breathe, or experiencing severe withdrawal, seek emergency medical care immediately. This app does not diagnose or treat conditions.'**
  String get supportEmergencyBody;

  /// No description provided for @supportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search resources'**
  String get supportSearchHint;

  /// No description provided for @supportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No additional verified resources available yet. You can still use the 1192 contact above.'**
  String get supportEmpty;

  /// No description provided for @supportNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No verified resources match these filters. You can still use the 1192 contact above.'**
  String get supportNoMatches;

  /// Opens the dialer with the provider's number; does not place the call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get supportCall;

  /// No description provided for @supportWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get supportWebsite;

  /// No description provided for @contactOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this contact.'**
  String get contactOpenFailed;

  /// No description provided for @kindHelpline.
  ///
  /// In en, this message translates to:
  /// **'Helpline'**
  String get kindHelpline;

  /// No description provided for @kindFacility.
  ///
  /// In en, this message translates to:
  /// **'Treatment facility'**
  String get kindFacility;

  /// No description provided for @kindNgo.
  ///
  /// In en, this message translates to:
  /// **'Support organisation'**
  String get kindNgo;

  /// No description provided for @kindEducation.
  ///
  /// In en, this message translates to:
  /// **'Education resource'**
  String get kindEducation;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'My next steps'**
  String get planTitle;

  /// No description provided for @planIntro.
  ///
  /// In en, this message translates to:
  /// **'Make room for small, achievable goals. They stay on this device in encrypted storage and are never uploaded.'**
  String get planIntro;

  /// No description provided for @planInputLabel.
  ///
  /// In en, this message translates to:
  /// **'One step I want to take'**
  String get planInputLabel;

  /// No description provided for @planInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Prepare my CV'**
  String get planInputHint;

  /// No description provided for @planAdd.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get planAdd;

  /// No description provided for @planProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed'**
  String planProgress(int done, int total);

  /// No description provided for @planEmpty.
  ///
  /// In en, this message translates to:
  /// **'No goals yet. Start with something small and important to you.'**
  String get planEmpty;

  /// No description provided for @planDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get planDelete;

  /// No description provided for @planSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save securely. Please try again.'**
  String get planSaveFailed;

  /// No description provided for @planUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update goal.'**
  String get planUpdateFailed;

  /// No description provided for @planDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete goal.'**
  String get planDeleteFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & privacy'**
  String get settingsTitle;

  /// No description provided for @settingsGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get settingsGuestTitle;

  /// No description provided for @settingsGuestBody.
  ///
  /// In en, this message translates to:
  /// **'No account required. This version does not create or upload a personal profile.'**
  String get settingsGuestBody;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy by design'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Goals are stored in encrypted device storage and excluded from backups. Public directory data may be kept for up to 24 hours for offline use. No medical history is collected.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get settingsLanguageSwahili;

  /// No description provided for @settingsSwahiliDraftNote.
  ///
  /// In en, this message translates to:
  /// **'The Kiswahili translation is a draft and is still being reviewed.'**
  String get settingsSwahiliDraftNote;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete my local data'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove saved listings, goals, preferences and cached directories.'**
  String get settingsDeleteBody;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete local data?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes goals, saved opportunities, preferences and cached public listings from this device.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Local app data cleared.'**
  String get settingsDeleted;

  /// No description provided for @settingsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear all data. Please retry.'**
  String get settingsDeleteFailed;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'HATUA v0.1.0 · Development preview'**
  String get settingsVersion;

  /// No description provided for @settingsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'HATUA is an information and referral tool, not a healthcare provider or a guarantee of employment.'**
  String get settingsDisclaimer;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
