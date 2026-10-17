import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/data/catalog_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _opportunityJson = {
  'id': 'a1', 'title': 'Example only', 'organisation': 'Example Org', 'summary': 'Test data',
  'category': 'training', 'county': 'Nairobi', 'eligibility': '', 'cost_label': '',
  'application_url': '', 'source_url': '', 'deadline': null, 'last_verified_at': null,
};

http.Client _okClient(List<Map<String, Object?>> body, {List<Uri>? seen}) => MockClient((request) async {
      seen?.add(request.url);
      return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
    });

http.Client _failingClient({int status = 503}) =>
    MockClient((request) async => http.Response('unavailable', status));

void main() {
  final t0 = DateTime(2026, 10, 18, 9);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('network success returns items and saves a timestamped public copy', () async {
    final seen = <Uri>[];
    final repo = CatalogRepository(
      client: _okClient([_opportunityJson], seen: seen), clock: () => t0,
      baseUrl: 'https://api.example.test', requireHttps: true,
    );
    final result = await repo.opportunities();
    expect(result.source, CatalogSource.network);
    expect(result.items.single.title, 'Example only');
    expect(result.fetchedAt, t0);
    expect(seen.single.toString(), 'https://api.example.test/api/v1/opportunities/');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogRepository.opportunitiesCacheKey), isNotNull);
  });

  test('falls back to a fresh cached copy when the server fails', () async {
    await CatalogRepository(client: _okClient([_opportunityJson]), clock: () => t0, requireHttps: false)
        .opportunities();
    final later = t0.add(const Duration(hours: 23));
    final result = await CatalogRepository(client: _failingClient(), clock: () => later, requireHttps: false)
        .opportunities();
    expect(result.source, CatalogSource.cache);
    expect(result.items, hasLength(1));
    expect(result.fetchedAt, t0);
  });

  test('discards cached copies older than 24 hours', () async {
    await CatalogRepository(client: _okClient([_opportunityJson]), clock: () => t0, requireHttps: false)
        .opportunities();
    final tooLate = t0.add(CatalogRepository.cacheLifetime);
    final result = await CatalogRepository(client: _failingClient(), clock: () => tooLate, requireHttps: false)
        .opportunities();
    expect(result.source, CatalogSource.unavailable);
    expect(result.items, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogRepository.opportunitiesCacheKey), isNull,
        reason: 'expired public listings must be deleted, not just hidden');
  });

  test('distrusts a cache stamped in the future (clock moved backwards)', () async {
    await CatalogRepository(client: _okClient([_opportunityJson]), clock: () => t0, requireHttps: false)
        .opportunities();
    final earlier = t0.subtract(const Duration(hours: 1));
    final result = await CatalogRepository(client: _failingClient(), clock: () => earlier, requireHttps: false)
        .opportunities();
    expect(result.source, CatalogSource.unavailable);
  });

  test('corrupt cache is removed rather than crashing', () async {
    SharedPreferences.setMockInitialValues({
      CatalogRepository.resourcesCacheKey: '{not json',
      '${CatalogRepository.resourcesCacheKey}.fetchedAt': t0.millisecondsSinceEpoch,
    });
    final result = await CatalogRepository(client: _failingClient(), clock: () => t0, requireHttps: false)
        .resources();
    expect(result.source, CatalogSource.unavailable);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogRepository.resourcesCacheKey), isNull);
  });

  test('non-array JSON from the server is rejected', () async {
    final client = MockClient((request) async => http.Response('{"detail":"oops"}', 200));
    final result = await CatalogRepository(client: client, clock: () => t0, requireHttps: false).resources();
    expect(result.source, CatalogSource.unavailable);
  });

  test('base URL defaults: emulator in debug/test, https production for release', () {
    expect(CatalogRepository.configuredBaseUrl, CatalogRepository.emulatorBaseUrl);
    expect(CatalogRepository.productionBaseUrl, startsWith('https://'));
    expect(CatalogRepository().baseUrl, CatalogRepository.emulatorBaseUrl);
  });

  test('release mode refuses plain http and never sends the request', () async {
    final seen = <Uri>[];
    final repo = CatalogRepository(
      client: _okClient([_opportunityJson], seen: seen), clock: () => t0,
      baseUrl: 'http://10.0.2.2:8000', requireHttps: true,
    );
    final result = await repo.opportunities();
    expect(seen, isEmpty);
    expect(result.source, CatalogSource.unavailable);
  });
}
