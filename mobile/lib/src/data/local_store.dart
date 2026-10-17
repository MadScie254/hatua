import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';
import 'catalog_repository.dart';
import 'counties.dart';

/// Everything HATUA keeps on the device. Nothing here is sent to the backend.
///
/// - Goal titles: encrypted storage (flutter_secure_storage, Android Keystore-backed).
/// - Bookmarks (public listing IDs), chosen county and language: plain SharedPreferences.
///   None of these reveal recovery status: bookmarks are only kept for opportunities,
///   never for support resources.
class LocalStore extends ChangeNotifier {
  LocalStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const goalsKey = 'hatua.goals.v1';
  static const savedKey = 'hatua.saved.opportunities.v1';
  static const countyKey = 'hatua.prefs.county.v1';
  static const localeKey = 'hatua.prefs.locale.v1';
  static const supportedLanguageCodes = <String>['en', 'sw'];
  static const maxGoalLength = 160;

  final FlutterSecureStorage _secureStorage;

  List<Goal> _goals = [];
  Set<String> _savedIds = {};
  String? _county;
  String? _languageCode;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool isSaved(String id) => _savedIds.contains(id);

  /// Chosen county, or null for all counties.
  String? get county => _county;

  /// Explicit app language, or null to follow the phone's language.
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds = prefs.getStringList(savedKey)?.toSet() ?? {};
    final county = prefs.getString(countyKey);
    _county = kenyanCounties.contains(county) ? county : null;
    final language = prefs.getString(localeKey);
    _languageCode = supportedLanguageCodes.contains(language) ? language : null;
    final stored = await _secureStorage.read(key: goalsKey);
    if (stored != null) {
      final raw = jsonDecode(stored) as List<dynamic>;
      _goals = raw.map((v) => Goal.fromJson(Map<String, dynamic>.from(v as Map))).toList();
    }
    notifyListeners();
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
    _goals = [
      ..._goals,
      Goal(id: DateTime.now().microsecondsSinceEpoch.toString(), title: clean, isDone: false),
    ];
    await _saveGoals();
  }

  Future<void> toggleGoal(String id) async {
    _goals = _goals.map((g) => g.id == id ? g.copyWith(isDone: !g.isDone) : g).toList();
    await _saveGoals();
  }

  Future<void> removeGoal(String id) async {
    _goals = _goals.where((g) => g.id != id).toList();
    await _saveGoals();
  }

  /// Removes every HATUA value from this device: goals, bookmarks, preferences, caches.
  Future<void> clearAll() async {
    _goals = [];
    _savedIds.clear();
    _county = null;
    _languageCode = null;
    await _secureStorage.delete(key: goalsKey);
    final prefs = await SharedPreferences.getInstance();
    for (final key in [savedKey, countyKey, localeKey, ...CatalogRepository.allCacheKeys]) {
      await prefs.remove(key);
    }
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    await _secureStorage.write(key: goalsKey, value: jsonEncode(_goals.map((g) => g.toJson()).toList()));
    notifyListeners();
  }
}
