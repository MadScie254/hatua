import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/app.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:hatua_app/src/models/application_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Explore tracks a listing; user changes progress in My Plan', (tester) async {
    useTallPhone(tester);
    final store = LocalStore(vault: FakeGoalVault());
    await store.load();
    await store.completeOnboarding();
    await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(store.applications, isEmpty);
    await tapVisible(tester, find.text('Nairobi job'));
    await tapVisible(tester, find.widgetWithText(OutlinedButton, 'Track application'));
    expect(store.applications.length, 1);
    expect(store.applications.single.stage, ApplicationStage.interested);

    expect(find.text('Tracked in My Plan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Plan'));
    await tester.pumpAndSettle();
    expect(find.text('My applications'), findsOneWidget);
    expect(find.text('Nairobi job'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<ApplicationStage>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applied').last);
    await tester.pumpAndSettle();
    expect(store.applications.single.stage, ApplicationStage.applied);
  });

  testWidgets('web may browse but cannot save private application tracking', (tester) async {
    useTallPhone(tester);
    final store = LocalStore(vault: FakeGoalVault(isSupported: false));
    await store.load();
    await store.completeOnboarding();
    await tester.pumpWidget(HatuaApp(store: store, repository: fakeRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Nairobi job'));
    expect(find.text('Apply at source'), findsOneWidget);
    expect(find.text('Track application'), findsNothing, reason: 'no secure vault on the web, so no offer');
    expect(store.applications, isEmpty);
  });
}
