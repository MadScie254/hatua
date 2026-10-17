import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';
import 'catalog_repository.dart';

/// Bookmarks contain only public IDs. Goal titles use encrypted device storage.
class LocalStore extends ChangeNotifier {
  static const _goalsKey = 'hatua.goals.v1';
  static const _savedKey = 'hatua.saved.opportunities.v1';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Goal> _goals = [];
  Set<String> _savedIds = {};
  List<Goal> get goals => List.unmodifiable(_goals);
  bool isSaved(String id) => _savedIds.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _savedIds = prefs.getStringList(_savedKey)?.toSet() ?? {};
    final stored = await _secureStorage.read(key: _goalsKey);
    if (stored != null) {
      final raw = jsonDecode(stored) as List<dynamic>;
      _goals = raw.map((v) => Goal.fromJson(Map<String, dynamic>.from(v as Map))).toList();
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    if (!_savedIds.add(id)) _savedIds.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, _savedIds.toList());
    notifyListeners();
  }

  Future<void> addGoal(String title) async {
    final clean = title.trim();
    if (clean.isEmpty || clean.length > 160) return;
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

  Future<void> clearAll() async {
    _goals = [];
    _savedIds.clear();
    await _secureStorage.delete(key: _goalsKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedKey);
    for (final key in CatalogRepository.allCacheKeys) {
      await prefs.remove(key);
    }
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    await _secureStorage.write(key: _goalsKey, value: jsonEncode(_goals.map((g) => g.toJson()).toList()));
    notifyListeners();
  }
}
