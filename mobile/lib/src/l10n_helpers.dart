import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'data/counties.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _localeTag => Localizations.localeOf(this).toLanguageTag();

  /// Day-month-year as written in Kenya: "18 Oct 2026" (month names localised in Kiswahili).
  /// An explicit pattern, because plain `en` would give the US order "Oct 18, 2026".
  String formatDate(DateTime value) => DateFormat('d MMM y', _localeTag).format(value.toLocal());

  /// "18 Oct 2026, 09:15" (24-hour clock, as commonly used in Kenya).
  String formatDateTime(DateTime value) =>
      '${formatDate(value)}, ${DateFormat.Hm(_localeTag).format(value.toLocal())}';
}

/// Opportunity category codes from the API (backend Opportunity.Category).
const opportunityCategories = <String>['job', 'training', 'grant', 'apprenticeship', 'other'];

/// Support resource kind codes from the API (backend SupportResource.Kind).
const supportKinds = <String>['helpline', 'facility', 'ngo', 'education'];

String categoryLabel(AppLocalizations l10n, String code) => switch (code) {
      'job' => l10n.categoryJob,
      'training' => l10n.categoryTraining,
      'grant' => l10n.categoryGrant,
      'apprenticeship' => l10n.categoryApprenticeship,
      _ => l10n.categoryOther,
    };

String kindLabel(AppLocalizations l10n, String code) => switch (code) {
      'helpline' => l10n.kindHelpline,
      'facility' => l10n.kindFacility,
      'ngo' => l10n.kindNgo,
      'education' => l10n.kindEducation,
      _ => code,
    };

String countyLabel(AppLocalizations l10n, String county) => county == nationwide ? l10n.countyNationwide : county;
