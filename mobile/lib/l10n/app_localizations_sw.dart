// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'HATUA';

  @override
  String get navHome => 'Mwanzo';

  @override
  String get navExplore => 'Fursa';

  @override
  String get navSupport => 'Msaada';

  @override
  String get navPlan => 'Mpango';

  @override
  String get navSettings => 'Mipangilio';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get cancel => 'Ghairi';

  @override
  String get delete => 'Futa';

  @override
  String get storageErrorMessage =>
      'Hifadhi salama ya kifaa haikuweza kufunguliwa. Tafadhali jaribu tena.';

  @override
  String get storageResetAction => 'Futa data ya kifaa kisha uendelee';

  @override
  String get homeGreeting => 'Karibu HATUA';

  @override
  String get homeTagline => 'Hatua moja mbele, kila siku.';

  @override
  String get homeQuestion => 'Ni nini kingekusaidia leo?';

  @override
  String get homeIntro =>
      'Gundua fursa, pata taarifa za msaada kwa siri, au panga hatua ndogo inayofuata.';

  @override
  String get homeFindOpportunities => 'Tafuta fursa';

  @override
  String get homeFindOpportunitiesSubtitle =>
      'Ajira, mafunzo na programu za kijamii zilizothibitishwa';

  @override
  String get homeFindSupport => 'Tafuta msaada';

  @override
  String get homeFindSupportSubtitle =>
      'Huduma za msaada zinazoaminika na simu za msaada za siri';

  @override
  String get homeNextSteps => 'Hatua zangu zijazo';

  @override
  String get homeNextStepsSubtitle =>
      'Fuatilia malengo yako kwa faragha kwenye kifaa chako';

  @override
  String get homeGuestNote =>
      'Vinjari bila vikwazo. Hakuna akaunti wala historia ya kibinafsi inayohitajika.';

  @override
  String get filterCounty => 'Kaunti';

  @override
  String get filterAllCounties => 'Kaunti zote';

  @override
  String get countyNationwide => 'Kitaifa';

  @override
  String get filterAll => 'Zote';

  @override
  String get clearFilters => 'Ondoa vichujio';

  @override
  String get statusCachedTitle => 'Nje ya mtandao au seva haipatikani';

  @override
  String statusCachedOpportunities(String when) {
    return 'Inaonyesha matangazo ya umma yaliyohifadhiwa $when. Hakiki tarehe za mwisho tena ukiwa mtandaoni.';
  }

  @override
  String statusCachedSupport(String when) {
    return 'Inaonyesha mawasiliano yaliyohifadhiwa $when. Nambari na saa za kazi huenda zimebadilika.';
  }

  @override
  String get statusUnavailableTitle => 'Imeshindikana kupakia orodha';

  @override
  String get statusUnavailableBody =>
      'Angalia muunganisho wako kisha ujaribu tena. Nakala zilizohifadhiwa hufutwa baada ya saa 24.';

  @override
  String get exploreTitle => 'Gundua fursa';

  @override
  String get exploreIntro =>
      'Matangazo ya umma hukaguliwa kabla ya kuchapishwa. Daima thibitisha maelezo kwenye chanzo asili.';

  @override
  String get exploreSearchHint => 'Tafuta ajira, mafunzo, mashirika';

  @override
  String get exploreSavedOnly => 'Zilizohifadhiwa pekee';

  @override
  String get exploreEmpty =>
      'Bado hakuna fursa zilizothibitishwa. Vuta chini ili kuonyesha upya ukiwa mtandaoni.';

  @override
  String get exploreNoMatches =>
      'Hakuna fursa zilizothibitishwa zinazolingana na vichujio hivi.';

  @override
  String get saveOpportunity => 'Hifadhi fursa';

  @override
  String get removeBookmark => 'Ondoa kwenye zilizohifadhiwa';

  @override
  String opportunityCloses(String date) {
    return 'Mwisho wa kutuma maombi: $date';
  }

  @override
  String opportunityCost(String cost) {
    return 'Gharama: $cost';
  }

  @override
  String opportunityEligibility(String text) {
    return 'Wanaostahili: $text';
  }

  @override
  String lastChecked(String date) {
    return 'Ilikaguliwa na HATUA mara ya mwisho $date';
  }

  @override
  String get applyAtSource => 'Omba kupitia chanzo rasmi';

  @override
  String get verifySource => 'Thibitisha chanzo';

  @override
  String get linkOpenFailed => 'Imeshindikana kufungua kiungo hiki.';

  @override
  String get categoryJob => 'Ajira';

  @override
  String get categoryTraining => 'Mafunzo';

  @override
  String get categoryGrant => 'Ruzuku / msaada wa kifedha';

  @override
  String get categoryApprenticeship => 'Uanagenzi';

  @override
  String get categoryOther => 'Nyingine';

  @override
  String get supportTitle => 'Tafuta msaada';

  @override
  String get supportIntro =>
      'Kutafuta msaada ni uamuzi wako binafsi. Vinjari bila kuingia kwenye akaunti wala kueleza historia yako.';

  @override
  String get supportTalkTitle => 'Ongea na mtu';

  @override
  String get supportNacadaBody =>
      'NACADA hutoa msaada kuhusu pombe na matumizi ya dawa za kulevya nchini Kenya kupitia 1192. Hii si huduma ya dharura ya ambulensi.';

  @override
  String get supportCall1192 => 'Fungua kipiga simu: 1192';

  @override
  String get supportEmergencyTitle => 'Wakati wa dharura';

  @override
  String get supportEmergencyBody =>
      'Ikiwa mtu amepoteza fahamu, anapata degedege, anatatizika kupumua, au ana dalili kali za kuacha pombe au dawa za kulevya, tafuta huduma ya dharura ya matibabu mara moja. Programu hii haitambui wala haitibu hali za kiafya.';

  @override
  String get supportSearchHint => 'Tafuta huduma';

  @override
  String get supportEmpty =>
      'Bado hakuna huduma nyingine zilizothibitishwa. Bado unaweza kutumia nambari 1192 iliyo hapo juu.';

  @override
  String get supportNoMatches =>
      'Hakuna huduma zilizothibitishwa zinazolingana na vichujio hivi. Bado unaweza kutumia nambari 1192 iliyo hapo juu.';

  @override
  String get supportCall => 'Piga simu';

  @override
  String get supportWebsite => 'Tovuti';

  @override
  String get contactOpenFailed => 'Imeshindikana kufungua mawasiliano haya.';

  @override
  String get kindHelpline => 'Simu ya msaada';

  @override
  String get kindFacility => 'Kituo cha matibabu';

  @override
  String get kindNgo => 'Shirika la msaada';

  @override
  String get kindEducation => 'Nyenzo ya elimu';

  @override
  String get planTitle => 'Hatua zangu zijazo';

  @override
  String get planIntro =>
      'Weka malengo madogo yanayowezekana. Yanabaki kwenye kifaa hiki katika hifadhi iliyosimbwa na hayapakiwi popote.';

  @override
  String get planInputLabel => 'Hatua moja ninayotaka kuchukua';

  @override
  String get planInputHint => 'mf. Kuandaa CV yangu';

  @override
  String get planAdd => 'Ongeza lengo';

  @override
  String planProgress(int done, int total) {
    return '$done kati ya $total yamekamilika';
  }

  @override
  String get planEmpty =>
      'Bado hakuna malengo. Anza na jambo dogo lenye umuhimu kwako.';

  @override
  String get planDelete => 'Futa lengo';

  @override
  String get planSaveFailed =>
      'Imeshindikana kuhifadhi kwa usalama. Tafadhali jaribu tena.';

  @override
  String get planUpdateFailed => 'Imeshindikana kusasisha lengo.';

  @override
  String get planDeleteFailed => 'Imeshindikana kufuta lengo.';

  @override
  String get settingsTitle => 'Mipangilio na faragha';

  @override
  String get settingsGuestTitle => 'Hali ya mgeni';

  @override
  String get settingsGuestBody =>
      'Huhitaji akaunti. Toleo hili halitengenezi wala kupakia wasifu wako binafsi.';

  @override
  String get settingsPrivacyTitle => 'Faragha tangu mwanzo';

  @override
  String get settingsPrivacyBody =>
      'Malengo huhifadhiwa kwenye hifadhi iliyosimbwa ya kifaa na hayajumuishwi kwenye nakala rudufu. Taarifa za orodha ya umma zinaweza kuhifadhiwa kwa hadi saa 24 kwa matumizi nje ya mtandao. Hakuna historia ya matibabu inayokusanywa.';

  @override
  String get settingsLanguageTitle => 'Lugha';

  @override
  String get settingsLanguageSystem => 'Lugha ya simu';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSwahili => 'Kiswahili';

  @override
  String get settingsSwahiliDraftNote =>
      'Tafsiri ya Kiswahili ni rasimu na bado inakaguliwa.';

  @override
  String get settingsDeleteTitle => 'Futa data yangu kwenye kifaa';

  @override
  String get settingsDeleteBody =>
      'Ondoa matangazo yaliyohifadhiwa, malengo, mapendeleo na orodha zilizohifadhiwa.';

  @override
  String get settingsDeleteConfirmTitle => 'Futa data ya kifaa?';

  @override
  String get settingsDeleteConfirmBody =>
      'Hii itaondoa kabisa malengo, fursa zilizohifadhiwa, mapendeleo na matangazo ya umma yaliyohifadhiwa kwenye kifaa hiki.';

  @override
  String get settingsDeleted => 'Data ya programu kwenye kifaa imefutwa.';

  @override
  String get settingsDeleteFailed =>
      'Imeshindikana kufuta data yote. Tafadhali jaribu tena.';

  @override
  String get settingsVersion => 'HATUA v0.1.0 · Toleo la majaribio';

  @override
  String get settingsDisclaimer =>
      'HATUA ni chombo cha taarifa na rufaa, si mtoa huduma za afya wala hakikisho la ajira.';
}
