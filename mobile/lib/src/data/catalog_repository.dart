import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/opportunity.dart';
import '../models/support_resource.dart';

/// Where a [CatalogResult] came from.
enum CatalogSource {
  /// Fetched from the API just now.
  network,

  /// Server unreachable; showing a public copy saved less than [CatalogRepository.cacheLifetime] ago.
  cache,

  /// Server unreachable and no usable saved copy.
  unavailable,
}

class CatalogResult<T> {
  const CatalogResult({required this.items, required this.source, this.fetchedAt});

  final List<T> items;
  final CatalogSource source;

  /// When [items] were downloaded from the server (null when [source] is unavailable).
  final DateTime? fetchedAt;

  bool get fromCache => source != CatalogSource.network;
}

/// Read-only access to the PUBLIC verified directory, with a short-lived offline copy.
///
/// The cache lives in SharedPreferences (not encrypted) and is therefore only suitable for
/// public listings. Never route personal or health data through this class.
class CatalogRepository {
  CatalogRepository({
    http.Client? client,
    DateTime Function()? clock,
    String? baseUrl,
    bool? requireHttps,
  })  : _client = client ?? http.Client(),
        _clock = clock ?? DateTime.now,
        baseUrl = baseUrl ?? configuredBaseUrl,
        requireHttps = requireHttps ?? kReleaseMode;

  static const _definedBaseUrl = String.fromEnvironment('HATUA_API_URL');

  /// Live pilot API (docs/DEPLOYMENT.md). Release builds use it unless HATUA_API_URL is set,
  /// e.g. to the Cloudflare edge URL.
  static const productionBaseUrl = 'https://hatua-api.vercel.app';

  /// Local Django dev server as seen from the Android emulator.
  static const emulatorBaseUrl = 'http://10.0.2.2:8000';

  /// `--dart-define=HATUA_API_URL=...` wins; otherwise production in release, emulator in debug.
  static String get configuredBaseUrl =>
      _definedBaseUrl.isNotEmpty ? _definedBaseUrl : (kReleaseMode ? productionBaseUrl : emulatorBaseUrl);

  /// Cached listings older than this are discarded so revoked or corrected entries
  /// do not linger on devices. See docs/CONTENT_VERIFICATION.md.
  static const cacheLifetime = Duration(hours: 24);
  static const requestTimeout = Duration(seconds: 12);

  static const opportunitiesCacheKey = 'hatua.cache.opportunities.v1';
  static const resourcesCacheKey = 'hatua.cache.resources.v1';

  /// Every SharedPreferences key this class writes; used by "Delete my local data".
  static const allCacheKeys = <String>[
    opportunitiesCacheKey,
    '$opportunitiesCacheKey.fetchedAt',
    resourcesCacheKey,
    '$resourcesCacheKey.fetchedAt',
  ];

  final http.Client _client;
  final DateTime Function() _clock;
  final String baseUrl;

  /// True in release builds: refuse to talk to the API over plain http.
  final bool requireHttps;

  Future<CatalogResult<Opportunity>> opportunities() =>
      _fetch('/api/v1/opportunities/', opportunitiesCacheKey, Opportunity.fromJson);

  Future<CatalogResult<SupportResource>> resources() =>
      _fetch('/api/v1/support-resources/', resourcesCacheKey, SupportResource.fromJson);

  void dispose() => _client.close();

  Future<CatalogResult<T>> _fetch<T>(
    String path,
    String cacheKey,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse('$baseUrl$path');
      if (requireHttps && uri.scheme != 'https') {
        throw StateError('HATUA_API_URL must use https in release builds');
      }
      final response = await _client.get(uri, headers: const {'Accept': 'application/json'})
          .timeout(requestTimeout);
      if (response.statusCode != 200) throw StateError('HTTP ${response.statusCode}');
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) throw const FormatException('Expected JSON array');
      final items = _parseList(decoded, parse);
      final now = _clock();
      await prefs.setString(cacheKey, jsonEncode(decoded));
      await prefs.setInt('$cacheKey.fetchedAt', now.millisecondsSinceEpoch);
      return CatalogResult(items: items, source: CatalogSource.network, fetchedAt: now);
    } catch (_) {
      return _fromCache(prefs, cacheKey, parse);
    }
  }

  Future<CatalogResult<T>> _fromCache<T>(
    SharedPreferences prefs,
    String cacheKey,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final cached = prefs.getString(cacheKey);
    final fetchedAtMs = prefs.getInt('$cacheKey.fetchedAt');
    if (cached != null && fetchedAtMs != null) {
      final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
      final age = _clock().difference(fetchedAt);
      // A negative age means the clock moved backwards; do not trust the copy.
      final fresh = !age.isNegative && age < cacheLifetime;
      if (fresh) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is List) {
            return CatalogResult(
              items: _parseList(decoded, parse),
              source: CatalogSource.cache,
              fetchedAt: fetchedAt,
            );
          }
        } catch (_) {
          // Fall through: an unparseable copy is discarded below.
        }
      }
    }
    // Stale, corrupt or missing: remove it so it can never be shown later.
    await prefs.remove(cacheKey);
    await prefs.remove('$cacheKey.fetchedAt');
    return CatalogResult(items: <T>[], source: CatalogSource.unavailable);
  }

  List<T> _parseList<T>(List<dynamic> raw, T Function(Map<String, dynamic>) parse) =>
      raw.map((value) => parse(Map<String, dynamic>.from(value as Map))).toList();
}
