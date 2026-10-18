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
      'Malengo binafsi na maombi yanayofuatiliwa husimbwa kwenye Android, hubaki kwenye simu na hayapo kwenye nakala rudufu. Data ya umma hukaa hadi saa 24. Hakuna historia ya matibabu inayokusanywa.';

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
      'Ondoa malengo, maombi yanayofuatiliwa, fursa na mapendeleo.';

  @override
  String get settingsDeleteConfirmTitle => 'Futa data ya kifaa?';

  @override
  String get settingsDeleteConfirmBody =>
      'Hii itafuta malengo, maombi yanayofuatiliwa, fursa zilizohifadhiwa, mapendeleo na data ya umma.';

  @override
  String get settingsDeleted => 'Data ya programu kwenye kifaa imefutwa.';

  @override
  String get settingsDeleteFailed =>
      'Imeshindikana kufuta data yote. Tafadhali jaribu tena.';

  @override
  String get settingsVersion => 'HATUA v0.2.0, toleo la majaribio';

  @override
  String get settingsDisclaimer =>
      'HATUA ni chombo cha taarifa na rufaa, si mtoa huduma za afya wala hakikisho la ajira.';

  @override
  String get planUnavailableTitle =>
      'Malengo binafsi hayapatikani kwenye simu hii';

  @override
  String get planUnavailableBody =>
      'Hifadhi salama ya simu hii haikuweza kutumika, kwa hivyo HATUA haitahifadhi malengo badala ya kuyaweka bila ulinzi. Sehemu nyingine zote za programu bado zinafanya kazi.';

  @override
  String get planResetGoals => 'Weka upya malengo binafsi';

  @override
  String get planResetConfirmTitle => 'Weka upya malengo binafsi?';

  @override
  String get planResetConfirmBody =>
      'Hii itafuta malengo ya faragha na maombi unayofuatilia kwa pamoja.';

  @override
  String get reset => 'Weka upya';

  @override
  String get technicalDetails => 'Maelezo ya kiufundi';

  @override
  String get planUnsupportedTitle =>
      'Mpango Wangu unapatikana kwenye programu ya Android';

  @override
  String get planUnsupportedBody =>
      'Malengo binafsi na ufuatiliaji wa maombi vinahitaji hifadhi salama ya Android. Toleo hili la wavuti halihifadhi hivyo.';

  @override
  String get settingsPrivacyBodyNoGoals =>
      'Toleo hili la wavuti halihifadhi malengo wala ufuatiliaji wa maombi. Fursa zilizohifadhiwa, kaunti, lugha na data ya umma hukaa kwenye kivinjari hiki. Hakuna historia ya matibabu inayokusanywa.';

  @override
  String get exploreTrack => 'Fuatilia ombi';

  @override
  String get exploreTracked => 'Linafuatiliwa kwenye Mpango';

  @override
  String get exploreTrackAdded => 'Limeongezwa kwenye Mpango.';

  @override
  String get exploreTrackAndroidOnly =>
      'Ufuatiliaji binafsi unahitaji hifadhi salama ya Android.';

  @override
  String get planApplicationsTitle => 'Maombi yangu';

  @override
  String get planApplicationsIntro =>
      'Fuatilia hatua kwa faragha. Kufungua kiungo si kutuma ombi.';

  @override
  String get planApplicationsEmpty =>
      'Bado hakuna ombi linalofuatiliwa. Ongeza kutoka Fursa.';

  @override
  String get planApplicationStatus => 'Hatua ya ombi';

  @override
  String get planApplicationRemove => 'Ondoa ombi';

  @override
  String get applicationStageInterested => 'Ninavutiwa';

  @override
  String get applicationStageApplied => 'Nimetuma ombi';

  @override
  String get applicationStageInterview => 'Mahojiano';

  @override
  String get applicationStageOffered => 'Nimepata ofa';

  @override
  String get applicationStageClosed => 'Limefungwa';

  @override
  String get homeTalkNowTitle => 'Ongea na mtu sasa';

  @override
  String get homeTalkNowBody =>
      'Simu ya msaada ya NACADA kuhusu pombe na dawa za kulevya, bila malipo, saa 24. Si huduma ya ambulensi.';

  @override
  String get homeCall1192 => 'Piga 1192';

  @override
  String get homeCountyChoose => 'Chagua kaunti yako';

  @override
  String homeCountySelected(String county) {
    return 'Inaonyesha $county kwanza';
  }

  @override
  String get changeCounty => 'Badilisha';

  @override
  String get detailsButton => 'Maelezo';

  @override
  String get detailAbout => 'Kuhusu';

  @override
  String get detailWhoCanApply => 'Nani anaweza kuomba';

  @override
  String get detailCost => 'Gharama';

  @override
  String get detailHowToApply => 'Jinsi ya kuomba';

  @override
  String get detailNoApplyLink =>
      'Hakuna fomu ya mtandaoni. Tumia mawasiliano yaliyo kwenye maelezo hapo juu.';

  @override
  String get deadlineNone => 'Hakuna tarehe ya mwisho iliyotajwa';

  @override
  String deadlineIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Inafungwa baada ya siku $days',
      one: 'Inafungwa kesho',
      zero: 'Inafungwa leo',
    );
    return '$_temp0';
  }

  @override
  String get copyToShare => 'Nakili ili kushiriki';

  @override
  String get copiedToShare =>
      'Imenakiliwa. Ibandike kwenye ujumbe ili kushiriki.';

  @override
  String get reportProblem => 'Ripoti tatizo';

  @override
  String get reportTitle => 'Kuna shida gani na tangazo hili?';

  @override
  String get reportReasonBrokenLink => 'Kiungo hakifanyi kazi';

  @override
  String get reportReasonWrongContact => 'Nambari ya simu au anwani si sahihi';

  @override
  String get reportReasonClosed => 'Imefungwa, imejaa au haitolewi tena';

  @override
  String get reportReasonScam => 'Inaonekana kuwa ulaghai au inaomba pesa';

  @override
  String get reportReasonOther => 'Jambo lingine';

  @override
  String get reportNoteLabel => 'Maelezo (si lazima)';

  @override
  String get reportNoteHint => 'Usiweke jina lako wala nambari yako ya simu.';

  @override
  String get reportPrivacy =>
      'Ripoti hazina majina. HATUA hairekodi aliyezituma.';

  @override
  String get reportSend => 'Tuma ripoti';

  @override
  String get reportSent => 'Ripoti imetumwa. Wafanyakazi wa HATUA wataikagua.';

  @override
  String get reportFailed =>
      'Ripoti haikutumwa. Angalia mtandao wako kisha ujaribu tena.';

  @override
  String get supportHelplinesTitle => 'Simu za msaada unazoweza kupiga sasa';

  @override
  String get supportNearTitle => 'Matibabu na msaada karibu nawe';

  @override
  String get supportNearChooseCounty =>
      'Chagua kaunti yako ili uone kwanza vituo vilivyoidhinishwa na NACADA vilivyo karibu nawe.';

  @override
  String supportNoneInCounty(String county) {
    return 'Bado hakuna vituo vilivyoorodheshwa $county. Huduma za kaunti nyingine ziko hapa chini.';
  }

  @override
  String get supportOtherCounties => 'Kaunti nyingine';

  @override
  String get supportMoreHelp => 'Msaada na taarifa zaidi';

  @override
  String get supportCopyNumber => 'Nakili nambari';

  @override
  String get numberCopied => 'Nambari imenakiliwa';

  @override
  String get supportDirections => 'Maelekezo ya njia';

  @override
  String get supportCallBefore =>
      'Piga simu kabla ya kusafiri ili kuthibitisha saa za kazi, huduma na gharama.';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matokeo $count',
      one: 'Tokeo 1',
      zero: 'Hakuna matokeo',
    );
    return '$_temp0';
  }

  @override
  String get welcomeLanguage => 'Chagua lugha yako';

  @override
  String get welcomePrivacyTitle => 'Faragha tangu mwanzo';

  @override
  String get welcomeNoAccount =>
      'Hakuna akaunti wala ufuatiliaji. Tumia kila kitu kama mgeni.';

  @override
  String get welcomeOnDevice =>
      'Kaunti yako na matangazo uliyohifadhi hubaki kwenye kifaa hiki.';

  @override
  String get welcomeSupportPrivate =>
      'Huduma za msaada unazotazama hazihifadhiwi kamwe.';

  @override
  String get welcomeCounty => 'Kaunti yako (si lazima)';

  @override
  String get welcomeStart => 'Anza';
}
