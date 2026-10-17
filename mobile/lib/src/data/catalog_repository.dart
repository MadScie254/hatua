import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/opportunity.dart';
import '../models/support_resource.dart';

class CatalogResult<T> {
  const CatalogResult({required this.items, required this.fromCache});
  final List<T> items;
  final bool fromCache;
}

/// Public, verified API data only. Cache is not suitable for private health data.
class CatalogRepository {
  const CatalogRepository();

  static const baseUrl = String.fromEnvironment(
    'HATUA_API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<CatalogResult<Opportunity>> opportunities() => _fetch(
        '/api/v1/opportunities/',
        'hatua.cache.opportunities.v1',
        Opportunity.fromJson,
      );

  Future<CatalogResult<SupportResource>> resources() => _fetch(
        '/api/v1/support-resources/',
        'hatua.cache.resources.v1',
        SupportResource.fromJson,
      );

  Future<CatalogResult<T>> _fetch<T>(
    String path,
    String cacheKey,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw StateError('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) throw const FormatException('Expected JSON array');
      final items = _parseList(decoded, parse);
      await prefs.setString(cacheKey, jsonEncode(decoded));
      await prefs.setInt('$cacheKey.fetchedAt', DateTime.now().millisecondsSinceEpoch);
      return CatalogResult(items: items, fromCache: false);
    } catch (_) {
      // Offline-safe for PUBLIC content. Fail with empty list if cache is invalid.
      final cached = prefs.getString(cacheKey);
      final fetchedAt = prefs.getInt('$cacheKey.fetchedAt');
      // Do not serve potentially revoked public listings indefinitely.
      const cacheLifetime = Duration(hours: 24);
      final cacheIsFresh = fetchedAt != null &&
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(fetchedAt)) < cacheLifetime &&
          DateTime.now().millisecondsSinceEpoch >= fetchedAt;
      if (cached != null && cacheIsFresh) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is List) {
            return CatalogResult(items: _parseList(decoded, parse), fromCache: true);
          }
        } catch (_) {
          // The cache cannot be trusted or parsed, so discard it.
          await prefs.remove(cacheKey);
          await prefs.remove('$cacheKey.fetchedAt');
        }
      }
      return CatalogResult(items: <T>[], fromCache: true);
    }
  }

  List<T> _parseList<T>(List<dynamic> raw, T Function(Map<String, dynamic>) parse) =>
      raw.map((value) => parse(Map<String, dynamic>.from(value as Map))).toList();
}
