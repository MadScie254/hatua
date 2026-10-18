import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/data/goal_vault.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:hatua_app/src/models/application_record.dart';
import 'package:hatua_app/src/models/opportunity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late FakeGoalVault vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = FakeGoalVault();
  });

  Future<LocalStore> opened() async {
    final store = LocalStore(vault: vault);
    await store.load();
    return store;
  }

  final listing = Opportunity.fromJson(opportunityJson('job-1', 'Apprentice electrician'));

  test('tracked applications and goals are encrypted in the same Android vault', () async {
    final store = await opened();
    await store.addGoal('Update my CV');
    await store.trackOpportunity(listing);
    await store.trackOpportunity(listing); // duplicate tap must not create another record
    expect(store.applications.length, 1);
    expect(store.applications.single.stage, ApplicationStage.interested);

    await store.updateApplicationStage('job-1', ApplicationStage.applied);
    final restored = await opened();
    expect(restored.goals.single.title, 'Update my CV');
    expect(restored.applications.single.stage, ApplicationStage.applied);
    expect(restored.applications.single.title, 'Apprentice electrician');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalStore.goalsKey), startsWith('fake1:'));
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key).toString();
      expect(value, isNot(contains('Apprentice electrician')));
      expect(value, isNot(contains('Update my CV')));
    }
  });

  test('legacy encrypted goal lists remain readable and migrate on write', () async {
    final legacy = jsonEncode([{'id': 'old', 'title': 'Existing goal', 'is_done': false}]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalStore.goalsKey, await vault.encrypt(legacy));
    final store = await opened();
    expect(store.goals.single.title, 'Existing goal');
    expect(store.applications, isEmpty);
    await store.trackOpportunity(listing);
    final restored = await opened();
    expect(restored.goals.single.title, 'Existing goal');
    expect(restored.applications.single.opportunityId, 'job-1');
  });

  test('deleting one tracked application preserves private goals', () async {
    final store = await opened();
    await store.addGoal('Private goal');
    await store.trackOpportunity(listing);
    await store.removeApplication('job-1');
    expect(store.applications, isEmpty);
    expect(store.goals.single.title, 'Private goal');
  });

  test('failed encryption cannot partially update the application tracker', () async {
    final store = await opened();
    vault.failWith = 'KeyStoreException: blocked';
    await expectLater(store.trackOpportunity(listing), throwsA(isA<GoalVaultException>()));
    expect(store.applications, isEmpty);
  });

  test('unsupported web vault cannot store private applications', () async {
    final webStore = LocalStore(vault: FakeGoalVault(isSupported: false));
    await webStore.load();
    expect(webStore.goalsStatus, GoalsStatus.unsupported);
    expect(() => webStore.trackOpportunity(listing), throwsStateError);
  });

  test('reset removes both goals and applications because they share one key', () async {
    final store = await opened();
    await store.addGoal('Private');
    await store.trackOpportunity(listing);
    await store.resetGoals();
    expect(store.goals, isEmpty);
    expect(store.applications, isEmpty);
    expect(vault.deleteCalls, 1);
  });
}
