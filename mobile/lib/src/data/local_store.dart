import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/application_record.dart';
import '../models/goal.dart';
import '../models/opportunity.dart';
import 'catalog_repository.dart';
import 'counties.dart';
import 'goal_vault.dart';

/// ready: goals work. unavailable: the vault failed on this device (see [LocalStore.goalsError]).
/// unsupported: this platform has no secure key store (web), so goals are never stored.
enum GoalsStatus { ready, unavailable, unsupported }

/// Everything HATUA keeps on the device. Nothing here is sent to the backend.
///
/// - Private goals and employment application tracker: encrypted by [GoalVault].
///   Previous goal-only ciphertext lists are migrated on the next write.
/// - Bookmarks (public listing IDs), chosen county and language: plain SharedPreferences.
///   None of these reveal recovery status: bookmarks are only kept for opportunities,
///   never for support resources.
///
/// Secure storage problems must never block the rest of the app: if the vault fails, goals
/// become [GoalsStatus.unavailable] and everything else (directory, 1192) keeps working.
class LocalStore extends ChangeNotifier {
  LocalStore({GoalVault? vault}) : _vault = vault ?? const PlatformGoalVault();

  // Keep the v1 preference key so existing encrypted goals survive the v2 envelope upgrade.
  static const goalsKey = 'hatua.goals.enc.v1';
  static const savedKey = 'hatua.saved.opportunities.v1';
  static const countyKey = 'hatua.prefs.county.v1';
  static const localeKey = 'hatua.prefs.locale.v1';
  static const onboardedKey = 'hatua.prefs.onboarded.v1';
  static const supportedLanguageCodes = <String>['en', 'sw'];
  static const maxGoalLength = 160;

  final GoalVault _vault;

  List<Goal> _goals = [];
  List<ApplicationRecord> _applications = [];
  GoalsStatus _goalsStatus = GoalsStatus.ready;
  String? _goalsError;
  Set<String> _savedIds = {};
  String? _county;
  String? _languageCode;
  bool _onboarded = false;

  List<Goal> get goals => List.unmodifiable(_goals);
  List<ApplicationRecord> get applications => List.unmodifiable(_applications);
  bool isTracked(String opportunityId) =>
      _applications.any((record) => record.opportunityId == opportunityId);
  GoalsStatus get goalsStatus => _goalsStatus;

  /// Technical reason goals are unavailable (exception type and message, no goal text).
  String? get goalsError => _goalsError;
  bool isSaved(String id) => _savedIds.contains(id);

  /// Chosen county, or null for all counties.
  String? get county => _county;

  /// True once the welcome screen (language, privacy, county) has been completed or skipped.
  bool get onboarded => _onboarded;

  /// Explicit app language, or null to follow the phone's language.
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);

  /// Loads preferences, then goals. Only a SharedPreferences failure is fatal; a vault failure
  /// marks goals unavailable instead of throwing.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds = prefs.getStringList(savedKey)?.toSet() ?? {};
    final county = prefs.getString(countyKey);
    _county = kenyanCounties.contains(county) ? county : null;
    final language = prefs.getString(localeKey);
    _languageCode = supportedLanguageCodes.contains(language) ? language : null;
    _onboarded = prefs.getBool(onboardedKey) ?? false;
    await _loadGoals(prefs);
    notifyListeners();
  }

  Future<void> retryGoals() async {
    await _loadGoals(await SharedPreferences.getInstance());
    notifyListeners();
  }

  /// Deletes saved goals and the key that protected them, then starts fresh.
  Future<void> resetGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(goalsKey);
    try {
      await _vault.deleteKey();
    } catch (_) {
      // A broken key that cannot be deleted will surface again on the next save.
    }
    _goals = [];
    _applications = [];
    _goalsStatus = _vault.isSupported ? GoalsStatus.ready : GoalsStatus.unsupported;
    _goalsError = null;
    notifyListeners();
  }

  Future<void> _loadGoals(SharedPreferences prefs) async {
    if (!_vault.isSupported) {
      _applications = [];
      _goals = [];
      _goalsStatus = GoalsStatus.unsupported;
      _goalsError = null;
      return;
    }
    final blob = prefs.getString(goalsKey);
    if (blob == null) {
      _applications = [];
      _goals = [];
      _goalsStatus = GoalsStatus.ready;
      _goalsError = null;
      return;
    }
    try {
      final decoded = jsonDecode(await _vault.decrypt(blob));
      // v1 saved only a JSON list of Goal records. v2 stores an envelope that
      // keeps private goals and the application tracker in one encrypted blob.
      final List<dynamic> goalsRaw;
      final List<dynamic> applicationsRaw;
      if (decoded is List) {
        goalsRaw = decoded;
        applicationsRaw = const [];
      } else if (decoded is Map && decoded['version'] == 2 &&
          decoded['goals'] is List && decoded['applications'] is List) {
        goalsRaw = decoded['goals'] as List<dynamic>;
        applicationsRaw = decoded['applications'] as List<dynamic>;
      } else {
        throw const FormatException('Unsupported private data version');
      }
      final goals = goalsRaw
          .map((v) => Goal.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
      final applications = applicationsRaw
          .map((v) => ApplicationRecord.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
      _goals = goals;
      _applications = applications;
      _goalsStatus = GoalsStatus.ready;
      _goalsError = null;
    } catch (e) {
      _applications = [];
      _goals = [];
      _goalsStatus = GoalsStatus.unavailable;
      _goalsError = e is GoalVaultException ? e.detail : e.runtimeType.toString();
    }
  }

  Future<void> toggleBookmark(String id) async {
    if (!_savedIds.add(id)) _savedIds.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(savedKey, _savedIds.toList());
    notifyListeners();
  }

  Future<void> setCounty(String? county) async {
    final value = kenyanCounties.contains(county) ? county : null;
    if (value == _county) return;
    _county = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(countyKey);
    } else {
      await prefs.setString(countyKey, value);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_onboarded) return;
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardedKey, true);
    notifyListeners();
  }

  Future<void> setLanguageCode(String? code) async {
    final value = supportedLanguageCodes.contains(code) ? code : null;
    if (value == _languageCode) return;
    _languageCode = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(localeKey);
    } else {
      await prefs.setString(localeKey, value);
    }
    notifyListeners();
  }

  /// A visit to an application URL is NOT evidence of submission.
  Future<void> trackOpportunity(Opportunity opportunity) {
    if (_goalsStatus != GoalsStatus.ready) {
      throw StateError('Private tracking is unavailable on this device');
    }
    if (isTracked(opportunity.id)) return Future.value();
    return _commitPrivate(
      applications: [..._applications, ApplicationRecord.fromOpportunity(opportunity, DateTime.now())],
    );
  }

  Future<void> updateApplicationStage(String id, ApplicationStage stage) {
    if (!isTracked(id)) return Future.value();
    return _commitPrivate(
      applications: [
        for (final record in _applications)
          record.opportunityId == id
              ? record.copyWith(stage: stage, updatedAt: DateTime.now().toUtc())
              : record,
      ],
    );
  }

  Future<void> removeApplication(String id) =>
      _commitPrivate(applications: _applications.where((r) => r.opportunityId != id).toList());

  Future<void> addGoal(String title) async {
    final clean = title.trim();
    if (clean.isEmpty || clean.length > maxGoalLength) return;
    await _commitPrivate(
      goals: [
        ..._goals,
        Goal(id: DateTime.now().microsecondsSinceEpoch.toString(), title: clean, isDone: false),
      ],
    );
  }

  Future<void> toggleGoal(String id) =>
      _commitPrivate(goals: _goals.map((g) => g.id == id ? g.copyWith(isDone: !g.isDone) : g).toList());

  Future<void> removeGoal(String id) => _commitPrivate(goals: _goals.where((g) => g.id != id).toList());

  /// Removes every personal HATUA value from this device: goals and their key, bookmarks,
  /// preferences and cached directories.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // The welcome-done flag is kept: it says nothing about the user, and wiping it would throw
    // them back to the welcome screen mid-session.
    for (final key in [goalsKey, savedKey, countyKey, localeKey, ...CatalogRepository.allCacheKeys]) {
      await prefs.remove(key);
    }
    _goals = [];
    _applications = [];
    _goalsStatus = _vault.isSupported ? GoalsStatus.ready : GoalsStatus.unsupported;
    _goalsError = null;
    _savedIds.clear();
    _county = null;
    _languageCode = null;
    notifyListeners();
    try {
      await _vault.deleteKey();
    } catch (_) {
      // Data is already gone; a stale key protects nothing.
    }
  }

  /// Atomically encrypts both sets of private records. No plaintext in preferences.
  /// In-memory state updates only after successful encryption and persistence.
  Future<void> _commitPrivate({List<Goal>? goals, List<ApplicationRecord>? applications}) async {
    if (_goalsStatus != GoalsStatus.ready) {
      throw StateError('Private storage is unavailable on this device');
    }
    final nextGoals = goals ?? _goals;
    final nextApplications = applications ?? _applications;
    final blob = await _vault.encrypt(jsonEncode({
      'version': 2,
      'goals': nextGoals.map((g) => g.toJson()).toList(),
      'applications': nextApplications.map((a) => a.toJson()).toList(),
    }));
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(goalsKey, blob)) throw StateError('Private storage write failed');
    _goals = nextGoals;
    _applications = nextApplications;
    notifyListeners();
  }
}
