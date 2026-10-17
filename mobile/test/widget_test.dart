import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/app.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:hatua_app/src/screens/explore_screen.dart';
import 'package:hatua_app/src/screens/home_screen.dart';
import 'package:hatua_app/src/screens/plan_screen.dart';
import 'package:hatua_app/src/screens/support_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    store = LocalStore();
    await store.load();
  });

  Future<void> pumpExplore(WidgetTester tester, {bool fail = false, double textScale = 1}) async {
    useTallPhone(tester);
    await tester.pumpWidget(localized(
      ExploreScreen(store: store, repository: fakeRepository(fail: fail), clock: () => testNow),
      textScale: textScale,
    ));
    await tester.pumpAndSettle();
  }

  group('Home', () {
    testWidgets('offers opportunity and support pathways', (tester) async {
      int? navigatedTo;
      await tester.pumpWidget(localized(HomeScreen(onNavigate: (index) => navigatedTo = index)));
      expect(find.text('Find opportunities'), findsOneWidget);
      expect(find.text('Find support'), findsOneWidget);
      await tester.tap(find.text('Find opportunities'));
      expect(navigatedTo, 1);
    });

    testWidgets('renders in Kiswahili', (tester) async {
      await tester.pumpWidget(localized(HomeScreen(onNavigate: (_) {}), locale: const Locale('sw')));
      await tester.pumpAndSettle();
      expect(find.text('Tafuta fursa'), findsOneWidget);
      expect(find.text('Tafuta msaada'), findsOneWidget);
    });
  });

  group('Explore', () {
    testWidgets('shows open listings with readable labels and hides closed ones', (tester) async {
      await pumpExplore(tester);
      expect(find.text('Nairobi job'), findsOneWidget);
      expect(find.text('Kisumu training'), findsOneWidget);
      expect(find.text('National grant'), findsOneWidget);
      expect(find.text('Closed job'), findsNothing, reason: 'deadline passed before testNow');
      expect(find.textContaining('Employment · Nairobi · Closes 30 Nov 2026'), findsOneWidget);
      expect(find.text('Last checked by HATUA on 1 Oct 2026'), findsNWidgets(3));
    });

    testWidgets('category chips filter the list', (tester) async {
      await pumpExplore(tester);
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Training'));
      expect(find.text('Kisumu training'), findsOneWidget);
      expect(find.text('Nairobi job'), findsNothing);
      expect(find.text('National grant'), findsNothing);
    });

    testWidgets('county choice keeps nationwide listings and is remembered', (tester) async {
      await pumpExplore(tester);
      await store.setCounty('Kisumu');
      await tester.pumpAndSettle();
      expect(find.text('Kisumu training'), findsOneWidget);
      expect(find.text('National grant'), findsOneWidget);
      expect(find.text('Nairobi job'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStore.countyKey), 'Kisumu');
    });

    testWidgets('no-match state offers to clear filters', (tester) async {
      await pumpExplore(tester);
      await store.setCounty('Mombasa');
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Apprenticeship'));
      expect(find.text('No verified opportunities match these filters.'), findsOneWidget);
      await tapVisible(tester, find.text('Clear filters'));
      expect(store.county, isNull);
      expect(find.text('Nairobi job'), findsOneWidget);
    });

    testWidgets('saved-only shows bookmarked listings', (tester) async {
      await pumpExplore(tester);
      await tapVisible(tester, find.byTooltip('Save opportunity').first);
      expect(store.isSaved('o1'), isTrue);
      await tapVisible(tester, find.text('Saved only'));
      expect(find.text('Nairobi job'), findsOneWidget);
      expect(find.text('Kisumu training'), findsNothing);
    });

    testWidgets('server down with no saved copy shows retry, not a misleading empty list', (tester) async {
      await pumpExplore(tester, fail: true);
      expect(find.text("Couldn't load the directory"), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      expect(find.text('No verified opportunities to show yet. Pull down to refresh when connected.'), findsNothing);
    });

    testWidgets('server down with a recent copy says it is offline data', (tester) async {
      await fakeRepository().opportunities(); // fills the cache at testNow
      await pumpExplore(tester, fail: true);
      expect(find.text('Offline or server unavailable'), findsOneWidget);
      expect(find.textContaining('saved 18 Oct 2026, 09:00'), findsOneWidget);
      expect(find.text('Nairobi job'), findsOneWidget);
    });
  });

  group('Support', () {
    testWidgets('1192 and emergency guidance are shown even when the server is down', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(localized(SupportScreen(store: store, repository: fakeRepository(fail: true))));
      await tester.pumpAndSettle();
      expect(find.text('Open dialer: 1192'), findsOneWidget);
      expect(find.text('In an emergency'), findsOneWidget);
      expect(find.textContaining('Not an emergency ambulance service'), findsOneWidget);
      expect(find.text("Couldn't load the directory"), findsOneWidget);
    });

    testWidgets('kind chips filter resources', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(localized(SupportScreen(store: store, repository: fakeRepository())));
      await tester.pumpAndSettle();
      expect(find.text('National helpline'), findsOneWidget);
      expect(find.text('Kisumu facility'), findsOneWidget);
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Helpline'));
      expect(find.text('National helpline'), findsOneWidget);
      expect(find.text('Kisumu facility'), findsNothing);
    });
  });

  group('My Plan', () {
    testWidgets('adds and completes a private goal', (tester) async {
      await tester.pumpWidget(localized(PlanScreen(store: store)));
      await tester.enterText(find.byType(TextField), 'Prepare my CV');
      await tester.tap(find.byTooltip('Add goal'));
      await tester.pumpAndSettle();
      expect(find.text('Prepare my CV'), findsOneWidget);
      expect(find.text('0 of 1 completed'), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.text('1 of 1 completed'), findsOneWidget);
    });
  });

  group('Accessibility: 200% text on a 360dp phone', () {
    for (final entry in <String, Widget Function(LocalStore)>{
      'Home': (_) => HomeScreen(onNavigate: (_) {}),
      'Explore': (s) => ExploreScreen(store: s, repository: fakeRepository(), clock: () => testNow),
      'Explore (Kiswahili)': (s) => ExploreScreen(store: s, repository: fakeRepository(), clock: () => testNow),
      'Support': (s) => SupportScreen(store: s, repository: fakeRepository()),
      'Plan': (s) => PlanScreen(store: s),
    }.entries) {
      testWidgets('${entry.key} lays out without overflow', (tester) async {
        usePhoneSize(tester);
        final locale = entry.key.contains('Kiswahili') ? const Locale('sw') : const Locale('en');
        await tester.pumpWidget(localized(entry.value(store), textScale: 2, locale: locale));
        await tester.pumpAndSettle();
        // RenderFlex overflows are reported as exceptions; there must be none.
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Whole app', () {
    testWidgets('does not download directories until their tab is opened', (tester) async {
      final requests = <String>[];
      await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository(requests: requests)));
      await tester.pumpAndSettle();
      expect(find.text('Karibu HATUA'), findsOneWidget);
      expect(requests, isEmpty);
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(requests, ['/api/v1/opportunities/']);
    });

    testWidgets('language can be switched to Kiswahili in Settings', (tester) async {
      useTallPhone(tester);
      await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Kiswahili'));
      expect(store.languageCode, 'sw');
      expect(find.text('Mipangilio'), findsWidgets);
      expect(find.text('Fursa'), findsOneWidget);
    });

    testWidgets('delete local data clears goals after confirmation', (tester) async {
      useTallPhone(tester);
      await store.addGoal('Private goal');
      await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Delete my local data'));
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(store.goals, isEmpty);
      expect(find.text('Local app data cleared.'), findsOneWidget);
    });
  });
}
