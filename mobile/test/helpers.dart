import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/l10n/app_localizations.dart';
import 'package:hatua_app/src/data/catalog_repository.dart';
import 'package:hatua_app/src/data/goal_vault.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Fixed "today" for deterministic deadline filtering.
final testNow = DateTime(2026, 10, 18, 9);

Map<String, Object?> opportunityJson(String id, String title, {
  String category = 'job',
  String county = 'Nairobi',
  String? deadline,
  String applicationUrl = 'https://example.invalid/apply',
  String sourceUrl = 'https://example.invalid/source',
}) => {
      'id': id, 'title': title, 'organisation': 'Example Org', 'summary': 'Test data only',
      'category': category, 'county': county, 'eligibility': '', 'cost_label': '',
      'application_url': applicationUrl, 'source_url': sourceUrl, 'deadline': deadline,
      'last_verified_at': '2026-10-01T08:00:00Z',
    };

Map<String, Object?> resourceJson(String id, String name, {
  String kind = 'ngo',
  String county = 'Nationwide',
  String phone = '',
}) => {
      'id': id, 'name': name, 'description': 'Test resource, not a real service', 'kind': kind,
      'county': county, 'phone': phone, 'website_url': '', 'location_label': '',
      'source_url': 'https://example.invalid/source', 'last_verified_at': '2026-10-01T08:00:00Z',
    };

final sampleOpportunities = [
  opportunityJson('o1', 'Nairobi job', deadline: '2026-11-30'),
  opportunityJson('o2', 'Kisumu training', category: 'training', county: 'Kisumu'),
  opportunityJson('o3', 'National grant', category: 'grant', county: 'Nationwide'),
  opportunityJson('o4', 'Closed job', deadline: '2026-10-01'),
];

final sampleResources = [
  resourceJson('s1', 'National helpline', kind: 'helpline', phone: '0800 000 000'),
  resourceJson('s2', 'Kisumu facility', kind: 'facility', county: 'Kisumu'),
];

/// Repository backed by an in-memory API. Records every requested path in [requests].
CatalogRepository fakeRepository({
  List<Map<String, Object?>>? opportunities,
  List<Map<String, Object?>>? resources,
  bool fail = false,
  List<String>? requests,
}) {
  final client = MockClient((request) async {
    requests?.add(request.url.path);
    if (fail) return http.Response('down', 503);
    final body = request.url.path.contains('opportunities')
        ? (opportunities ?? sampleOpportunities)
        : (resources ?? sampleResources);
    return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json; charset=utf-8'});
  });
  return CatalogRepository(client: client, clock: () => testNow, baseUrl: 'http://api.test', requireHttps: false);
}

/// Wraps [child] in a localised MaterialApp, optionally with large text.
Widget localized(Widget child, {Locale locale = const Locale('en'), double textScale = 1}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, inner) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: inner!,
      ),
      home: Scaffold(body: child),
    );

/// A small Android phone (360x640 dp).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// A 360dp-wide phone tall enough that list tests can see every card without scrolling.
void useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 7200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Taps a widget after scrolling it into view (chips live in a horizontal scroller).
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// In-memory stand-in for the Android Keystore vault. "Encrypts" by base64 + reversal so tests
/// can prove plaintext never reaches SharedPreferences. Set [failWith] to simulate a broken
/// Keystore (as seen on a pilot phone).
class FakeGoalVault implements GoalVault {
  String? failWith;
  int deleteCalls = 0;

  @override
  Future<String> encrypt(String plainText) async {
    if (failWith != null) throw GoalVaultException(failWith!);
    return 'fake1:${String.fromCharCodes(base64Encode(utf8.encode(plainText)).codeUnits.reversed)}';
  }

  @override
  Future<String> decrypt(String blob) async {
    if (failWith != null) throw GoalVaultException(failWith!);
    if (!blob.startsWith('fake1:')) throw const GoalVaultException('bad blob');
    return utf8.decode(base64Decode(String.fromCharCodes(blob.substring(6).codeUnits.reversed)));
  }

  @override
  Future<void> deleteKey() async => deleteCalls++;
}
