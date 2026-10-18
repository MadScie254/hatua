import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/data/catalog_repository.dart';
import 'package:hatua_app/src/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late FakeGoalVault vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = FakeGoalVault();
  });

  Future<LocalStore> loaded() async {
    final store = LocalStore(vault: vault);
    await store.load();
    return store;
  }

  test('goals persist as ciphertext only; plaintext never reaches preferences', () async {
    final store = await loaded();
    await store.addGoal('  Visit the county youth office  ');
    await store.toggleGoal(store.goals.single.id);

    final reloaded = await loaded();
    expect(reloaded.goals.single.title, 'Visit the county youth office');
    expect(reloaded.goals.single.isDone, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalStore.goalsKey), startsWith('fake1:'));
    for (final key in prefs.getKeys()) {
      expect(prefs.get(key).toString(), isNot(contains('youth office')),
          reason: 'goal text must never be written to preferences in plaintext');
    }
  });

  test('rejects empty and over-long goals', () async {
    final store = await loaded();
    await store.addGoal('   ');
    await store.addGoal('x' * (LocalStore.maxGoalLength + 1));
    expect(store.goals, isEmpty);
  });

  test('a broken Keystore never blocks loading; goals become unavailable with details', () async {
    final store = await loaded();
    await store.addGoal('Private');
    vault.failWith = 'KeyStoreException: device keystore unavailable';

    final broken = LocalStore(vault: vault);
    await broken.load(); // must not throw
    expect(broken.goalsStatus, GoalsStatus.unavailable);
    expect(broken.goalsError, contains('KeyStoreException'));
    expect(broken.goals, isEmpty);
    expect(() => broken.addGoal('x'), throwsStateError);

    vault.failWith = null;
    await broken.retryGoals();
    expect(broken.goalsStatus, GoalsStatus.ready);
    expect(broken.goals.single.title, 'Private', reason: 'retry recovers data when the key works again');
  });

  test('fresh install with a broken Keystore still opens with no goals', () async {
    vault.failWith = 'ProviderException: boom';
    final store = await loaded();
    expect(store.goalsStatus, GoalsStatus.ready, reason: 'nothing stored yet, nothing to decrypt');
    await expectLater(store.addGoal('First goal'), throwsA(anything));
    expect(store.goals, isEmpty, reason: 'in-memory list only changes after a successful write');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalStore.goalsKey), isNull);
  });

  test('reset deletes ciphertext and key and starts fresh', () async {
    final store = await loaded();
    await store.addGoal('Private');
    vault.failWith = 'AEADBadTagException: tag mismatch';
    final broken = LocalStore(vault: vault);
    await broken.load();
    vault.failWith = null;
    await broken.resetGoals();
    expect(broken.goalsStatus, GoalsStatus.ready);
    expect(broken.goals, isEmpty);
    expect(vault.deleteCalls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalStore.goalsKey), isNull);
  });

  test('county and language accept only known values', () async {
    final store = await loaded();
    await store.setCounty('Kisumu');
    await store.setLanguageCode('sw');
    expect(store.county, 'Kisumu');
    expect(store.languageCode, 'sw');
    await store.setCounty('Atlantis');
    await store.setLanguageCode('fr');
    expect(store.county, isNull);
    expect(store.languageCode, isNull);
  });

  test('ignores tampered preference values on load', () async {
    SharedPreferences.setMockInitialValues({LocalStore.countyKey: 'Atlantis', LocalStore.localeKey: 'xx'});
    final store = await loaded();
    expect(store.county, isNull);
    expect(store.locale, isNull);
  });

  test('clearAll removes every HATUA value and the key', () async {
    SharedPreferences.setMockInitialValues({
      for (final key in CatalogRepository.allCacheKeys) key: key.endsWith('fetchedAt') ? 1 : '[]',
    });
    final store = await loaded();
    await store.addGoal('Private');
    await store.toggleBookmark('o1');
    await store.setCounty('Nairobi');
    await store.setLanguageCode('sw');

    await store.clearAll();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
    expect(vault.deleteCalls, 1);
    expect(store.goals, isEmpty);
    expect(store.applications, isEmpty);
    expect(store.isSaved('o1'), isFalse);
    expect(store.county, isNull);
    expect(store.languageCode, isNull);
  });
}
