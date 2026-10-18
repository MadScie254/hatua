import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/app.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:hatua_app/src/screens/explore_screen.dart';
import 'package:hatua_app/src/screens/home_screen.dart';
import 'package:hatua_app/src/screens/support_screen.dart';
import 'package:hatua_app/src/widgets/directory_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// End-to-end journeys a guest takes: first launch, finding and opening a listing, reaching a
/// service, and reporting a problem.
void main() {
  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalStore(vault: FakeGoalVault());
    await store.load();
  });

  group('First launch', () {
    testWidgets('welcome asks language and county once, then opens the app', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository()));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Kiswahili'));
      await tester.pumpAndSettle();
      expect(store.languageCode, 'sw');
      expect(find.text('Chagua lugha yako'), findsOneWidget);

      await tester.tap(find.text('Anza'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(LocalStore.onboardedKey), isTrue);

      // A fresh start of the app goes straight to Home.
      final again = LocalStore(vault: FakeGoalVault());
      await tester.pumpWidget(HatuaApp(store: again, repository: fakeRepository()));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('deleting local data keeps the user in the app', (tester) async {
      await store.completeOnboarding();
      await store.clearAll();
      expect(store.onboarded, isTrue);
    });
  });

  group('Home', () {
    testWidgets('1192 is one tap away and the county can be chosen', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(localized(HomeScreen(onNavigate: (_) {}, store: store)));
      await tester.pumpAndSettle();
      expect(find.text('Talk to someone now'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Call 1192'), findsOneWidget);
      await tester.tap(find.text('Choose your county'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Kisumu'), 200, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Kisumu'));
      await tester.pumpAndSettle();
      expect(store.county, 'Kisumu');
      expect(find.text('Showing Kisumu first'), findsOneWidget);
    });
  });

  group('Opportunity details', () {
    Future<void> openNairobiJob(WidgetTester tester, {List<Map<String, dynamic>>? reports}) async {
      useTallPhone(tester);
      await tester.pumpWidget(localized(ExploreScreen(
        store: store,
        repository: fakeRepository(reports: reports),
        clock: () => testNow,
      )));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Nairobi job'));
    }

    testWidgets('shows everything needed to act, with the source and check date', (tester) async {
      await openNairobiJob(tester);
      expect(find.text('Example Org'), findsOneWidget);
      expect(find.text('Closes 30 Nov 2026'), findsOneWidget);
      expect(find.text('Who can apply'), findsNothing, reason: 'sample has no eligibility text');
      expect(find.widgetWithText(FilledButton, 'Apply at source'), findsOneWidget);
      expect(find.text('Verify source'), findsOneWidget);
      expect(find.text('Last checked by HATUA on 1 Oct 2026'), findsOneWidget);
      expect(find.text('Track application'), findsOneWidget, reason: 'Android vault available');
      await tester.tap(find.byTooltip('Save opportunity'));
      await tester.pumpAndSettle();
      expect(store.isSaved('o1'), isTrue);
    });

    testWidgets('report a problem sends only the listing, reason and note', (tester) async {
      final reports = <Map<String, dynamic>>[];
      await openNairobiJob(tester, reports: reports);
      await tapVisible(tester, find.text('Report a problem'));
      expect(find.text('Reports are anonymous. HATUA does not record who sent them.'), findsOneWidget);
      final send = find.widgetWithText(FilledButton, 'Send report');
      expect(tester.widget<FilledButton>(send).onPressed, isNull, reason: 'a reason is required');
      await tester.tap(find.text('It looks like a scam or asks for money'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  They asked for a registration fee  ');
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(reports, [
        {'record_type': 'opportunity', 'record_id': 'o1', 'reason': 'suspected_scam', 'note': 'They asked for a registration fee'},
      ]);
      expect(find.text('Report sent. HATUA staff will check this listing.'), findsOneWidget);
    });
  });

  test('deadline countdown counts calendar days', () {
    expect(daysUntil(DateTime(2026, 10, 18), DateTime(2026, 10, 18, 23, 59)), 0);
    expect(daysUntil(DateTime(2026, 10, 19), DateTime(2026, 10, 18, 9)), 1);
    expect(daysUntil(DateTime(2026, 11, 30), DateTime(2026, 10, 18, 9)), 43);
  });

  group('Support', () {
    final resources = [
      resourceJson('h1', 'National helpline', kind: 'helpline', phone: '0800 000 000'),
      {...resourceJson('f1', 'Kisumu centre', kind: 'facility', county: 'Kisumu', phone: '0700 000 001'), 'location_label': 'Nyamasaria'},
      resourceJson('f2', 'Nairobi centre', kind: 'facility', county: 'Nairobi', phone: '0700 000 002'),
      resourceJson('i1', 'Accreditation list', kind: 'education'),
    ];

    Future<void> pumpSupport(WidgetTester tester, {List<Map<String, dynamic>>? reports}) async {
      useTallPhone(tester);
      await tester.pumpWidget(localized(SupportScreen(
        store: store,
        repository: fakeRepository(resources: resources, reports: reports),
      )));
      await tester.pumpAndSettle();
    }

    testWidgets('helplines first, then centres grouped by county, then information', (tester) async {
      await pumpSupport(tester);
      double y(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(y('Helplines you can call now'), lessThan(y('National helpline')));
      expect(y('National helpline'), lessThan(y('Treatment and support near you')));
      expect(y('Kisumu centre'), lessThan(y('Nairobi centre')), reason: 'counties in A-Z order');
      expect(y('Nairobi centre'), lessThan(y('More help and information')));
      expect(find.text('Choose your county to see NACADA-accredited centres near you first.'), findsOneWidget);
      expect(find.byTooltip('Call Nairobi centre'), findsOneWidget);
    });

    testWidgets('choosing a county shows its centres and hides other counties', (tester) async {
      await pumpSupport(tester);
      await store.setCounty('Nairobi');
      await tester.pumpAndSettle();
      expect(find.text('Nairobi centre'), findsOneWidget);
      expect(find.text('Kisumu centre'), findsNothing);
      expect(find.text('National helpline'), findsOneWidget);
    });

    testWidgets('a county with no centres says so and still shows the others', (tester) async {
      await pumpSupport(tester);
      await store.setCounty('Turkana');
      await tester.pumpAndSettle();
      expect(find.text('No listed centres in Turkana yet. Services in other counties are below.'), findsOneWidget);
      expect(find.text('Kisumu centre'), findsOneWidget);
    });

    testWidgets('details offer call, copy, directions and an anonymous report', (tester) async {
      final reports = <Map<String, dynamic>>[];
      await pumpSupport(tester, reports: reports);
      await tapVisible(tester, find.text('Kisumu centre'));
      expect(find.widgetWithText(FilledButton, 'Call 0700 000 001'), findsOneWidget);
      expect(find.text('Copy number'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Call before you travel to confirm opening hours, services and fees.'), findsOneWidget);
      expect(find.byTooltip('Save opportunity'), findsNothing, reason: 'support is never bookmarked');
      await tapVisible(tester, find.text('Report a problem'));
      await tester.tap(find.text('The phone number or address is wrong'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Send report'));
      await tester.pumpAndSettle();
      expect(reports.single, {'record_type': 'support_resource', 'record_id': 'f1', 'reason': 'wrong_contact'});
    });
  });

  test('map links search for the listed place, never coordinates', () {
    final url = Uri.parse(mapsSearchUrl('Kisumu centre', 'Nyamasaria', 'Kisumu'));
    expect(url.host, 'www.google.com');
    expect(url.queryParameters['query'], 'Kisumu centre, Nyamasaria, Kisumu, Kenya');
  });
}
