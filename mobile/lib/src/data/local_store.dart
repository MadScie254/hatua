import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';
import 'catalog_repository.dart';
import 'counties.dart';
import 'goal_vault.dart';

/// ready: goals work. unavailable: the vault failed on this device (see [LocalStore.goalsError]).
/// unsupported: this platform has no secure key store (web), so goals are never stored.
enum GoalsStatus { ready, unavailable, unsupported }

/// Everything HATUA keeps on the device. Nothing here is sent to the backend.
///
/// - Goal titles: encrypted by [GoalVault] (Android Keystore AES-GCM); only ciphertext is stored.
/// - Bookmarks (public listing IDs), chosen county and language: plain SharedPreferences.
///   None of these reveal recovery status: bookmarks are only kept for opportunities,
///   never for support resources.
///
/// Secure storage problems must never block the rest of the app: if the vault fails, goals
/// become [GoalsStatus.unavailable] and everything else (directory, 1192) keeps working.
class LocalStore extends ChangeNotifier {
  LocalStore({GoalVault? vault}) : _vault = vault ?? const PlatformGoalVault();

  static const goalsKey = 'hatua.goals.enc.v1';
  static const savedKey = 'hatua.saved.opportunities.v1';
  static const countyKey = 'hatua.prefs.county.v1';
  static const localeKey = 'hatua.prefs.locale.v1';
  static const supportedLanguageCodes = <String>['en', 'sw'];
  static const maxGoalLength = 160;

  final GoalVault _vault;

  List<Goal> _goals = [];
  GoalsStatus _goalsStatus = GoalsStatus.ready;
  String? _goalsError;
  Set<String> _savedIds = {};
  String? _county;
  String? _languageCode;

  List<Goal> get goals => List.unmodifiable(_goals);
  GoalsStatus get goalsStatus => _goalsStatus;

  /// Technical reason goals are unavailable (exception type and message, no goal text).
  String? get goalsError => _goalsError;
  bool isSaved(String id) => _savedIds.contains(id);

  /// Chosen county, or null for all counties.
  String? get county => _county;

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
    _goalsStatus = _vault.isSupported ? GoalsStatus.ready : GoalsStatus.unsupported;
    _goalsError = null;
    notifyListeners();
  }

  Future<void> _loadGoals(SharedPreferences prefs) async {
    if (!_vault.isSupported) {
      _goals = [];
      _goalsStatus = GoalsStatus.unsupported;
      _goalsError = null;
      return;
    }
    final blob = prefs.getString(goalsKey);
    if (blob == null) {
      _goals = [];
      _goalsStatus = GoalsStatus.ready;
      _goalsError = null;
      return;
    }
    try {
      final raw = jsonDecode(await _vault.decrypt(blob)) as List<dynamic>;
      _goals = raw.map((v) => Goal.fromJson(Map<String, dynamic>.from(v as Map))).toList();
      _goalsStatus = GoalsStatus.ready;
      _goalsError = null;
    } catch (e) {
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

  Future<void> addGoal(String title) async {
    final clean = title.trim();
    if (clean.isEmpty || clean.length > maxGoalLength) return;
    await _commitGoals([
      ..._goals,
      Goal(id: DateTime.now().microsecondsSinceEpoch.toString(), title: clean, isDone: false),
    ]);
  }

  Future<void> toggleGoal(String id) =>
      _commitGoals(_goals.map((g) => g.id == id ? g.copyWith(isDone: !g.isDone) : g).toList());

  Future<void> removeGoal(String id) => _commitGoals(_goals.where((g) => g.id != id).toList());

  /// Removes every HATUA value from this device: goals and their key, bookmarks, preferences, caches.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [goalsKey, savedKey, countyKey, localeKey, ...CatalogRepository.allCacheKeys]) {
      await prefs.remove(key);
    }
    _goals = [];
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

  /// Encrypts and stores [next]; the in-memory list changes only if the write succeeded.
  Future<void> _commitGoals(List<Goal> next) async {
    if (_goalsStatus != GoalsStatus.ready) {
      throw StateError('Goals are unavailable on this device');
    }
    final blob = await _vault.encrypt(jsonEncode(next.map((g) => g.toJson()).toList()));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(goalsKey, blob);
    _goals = next;
    notifyListeners();
  }
}
